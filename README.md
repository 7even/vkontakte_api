# vkontakte_api [![Build Status](https://secure.travis-ci.org/7even/vkontakte_api.png)](http://travis-ci.org/7even/vkontakte_api) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/7even/vkontakte_api)

`vkontakte_api` is a Ruby wrapper for VKontakte API. It allows you to call all API methods in the simplest possible way.

Below is the English version of the readme. Russian version is located [here](https://github.com/7even/vkontakte_api/blob/master/README.ru.md).

## Installation

``` bash
$ gem install vkontakte_api
```

## Usage

All requests are sent via `VkontakteApi::Client` instance.

``` ruby
@app = VkontakteApi::Client.new
```

To create a client able to perform authorized requests you need to pass an access token.

``` ruby
@app = VkontakteApi::Client.new('my_access_token')
```

Probably the easiest way to get an access token in a web-app is using [OmniAuth](https://github.com/intridea/omniauth), but you can roll your own authentication if for some reason `OmniAuth` isn't acceptable. Currently `vkontakte_api` doesn't offer authentication functionality.

Now you can call the API methods. All method names are underscore_cased as opposed to the [official documentation](http://vk.com/developers.php?oid=-17680044&p=API_Method_Description) where they are camelCased, so `getGroups` becomes `get_groups`. You can still call them in a camelCased manner, but that is not a Ruby-way practice.

``` ruby
@app.get_user_settings  # => 327710
@app.groups.get         # => [1, 31022447]
```

Predicate methods (those which begin with `is`, like `is_app_user`) are expected to return the result of some condition, so the '?' is appended to the end of the method name, and they return `true` or `false`:

``` ruby
@app.is_app_user? # => true
```

You can still call these without a '?' and get `'1'` or `'0'` in result if you want to handle that yourself.

Now for parameters. All method parameters are named, and you can pass them in a hash where parameter names are keys and parameter values are values:

``` ruby
@app.friends.get(fields: 'uid,first_name,last_name')
# =>  [
#       {
#         :uid          => "1",
#         :first_name   => "Павел",
#         :last_name    => "Дуров"
#       },
#       {
#         :uid          => "6492",
#         :first_name   => "Andrew",
#         :last_name    => "Rogozov"
#       }
#     ]
```

If the parameter value is a comma-separated list, you can pass it as an array - it will be properly handled before the request:

``` ruby
users_ids = [1, 6492]
@app.users.get(uids: users_ids) # => same output as above
```

All hashes in method results are wrapped in `Hashie::Mash` so you can access their attributes by string keys, symbol keys or accessor methods. So, continuing the example above:

``` ruby
users = @app.users.get(uids: users_ids)
users.first[:uid]        # => "1"
users.last['first_name'] # => "Andrew"
users.last.last_name     # => "Rogozov"
# let's check if the first user has a uid
users.first.uid?         # => true
```

If the response is an Enumerable, you can pass a block that will yield each successive element and put the result in the returned array (like `Enumerable#map` does):

``` ruby
@app.friends.get(fields: 'first_name,last_name') do |friend|
  "#{friend.first_name} #{friend.last_name}"
end
# => ["Павел Дуров", "Andrew Rogozov"]
```

`vkontakte_api` doesn't keep any method names list inside (except method namespaces like `friends` or `groups`) - when you call a method, it's name is camelcased before sending a request to VKontakte. So when a new method is added to the API, you don't need to wait for the new version of `vkontakte_api` gem - you can use that new method immediately. If you mistype the method name or use a method you don't have rights to call, you will get an exception with a relevant message (more about the exceptions below).

### Error handling

If VKontakte returns an error in response, you get a `VkontakteApi::Error` exception with all meaningful information that can be retrieved:

``` ruby
@app.audio.get_by_id
# => VkontakteApi::Error: VKontakte returned an error 1: 'Unknown error occured' after calling method 'audio.getById' without parameters.
```

## Customization

Global library settings can be specified in `VkontakteApi.configure` block:

``` ruby
VkontakteApi.configure do |config|
  config.adapter       = :net_http
  config.logger        = Rails.logger
  config.log_errors    = true
  config.log_responses = false
end
```

* default HTTP request library is `Net::HTTP`; you can set [any other adapter](https://github.com/technoweenie/faraday/blob/master/lib/faraday/adapter.rb) supported by `faraday`
* standard logger outputs everything to `STDOUT`; it makes sense to set `Rails.logger` as a logger if you are in a rails app
* by default only error JSON is logged; you can also log successful responses if you wish (errors are logged with a `warn` level, successful responses - with `debug`)

## Y U NO USE MULTI_JSON?

The only parser that appears to successfully process VKontakte JSON is `Oj`. Here's the example with `multi_json`:

``` bash
$ pry -r faraday -r multi_json
```

``` ruby
response = Faraday.get('https://api.vkontakte.ru/method/groups.getById?gids=23201%2C23202%2C23203&fields=country%2Ccity')
# => #<Faraday::Response:0x7f846b829dc0 ...>
MultiJson.adapter
# => MultiJson::Adapters::Oj < Object
MultiJson.decode(response.body)
# success

MultiJson.use :yajl
MultiJson.decode(response.body)
# => MultiJson::DecodeError: lexical error: invalid character inside string.

MultiJson.use :json_gem
MultiJson.decode(response.body)
# => MultiJson::DecodeError: 387: unexpected token at ...

MultiJson.use :json_pure
MultiJson.decode(response.body)
# => MultiJson::DecodeError: 387: unexpected token at ...

MultiJson.use :ok_json
MultiJson.decode(response.body)
# => Encoding::CompatibilityError: incompatible character encodings: UTF-8 and ASCII-8BIT
```

This example is actual for the moment of writing, but the data is dynamic so these errors may disappear over time.

## Changelog

* 0.1 Initial stable version
* 0.2 Array arguments support, cleaned up non-authorized requests, updated namespaces list, code documentation
* 0.2.1 `stats` namespace
* 1.0 Customizable logger, `Hashie::Mash` method results, json parsed by Oj

## Roadmap

* Authentication (getting the access_token from VK)
* Uploading files to vk.com servers
* Rails generator for initializer

## Contributing

If you want to contribute to the project, fork the repository, push your changes to a topic branch and send me a pull request.

`vkontakte_api` is tested under MRI `1.8.7`, `1.9.2` and `1.9.3`. If something is working incorrectly or not working at all in one of these environments, this should be considered a bug. Any bug reports are welcome at [Github issues](https://github.com/7even/vkontakte_api/issues).
