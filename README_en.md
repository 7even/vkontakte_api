## vkontakte_api [![Build Status](https://secure.travis-ci.org/7even/vkontakte_api.png)](http://travis-ci.org/7even/vkontakte_api) [![Gem Version](https://badge.fury.io/rb/vkontakte_api.png)](http://badge.fury.io/rb/vkontakte_api) [![Dependency Status](https://gemnasium.com/7even/vkontakte_api.png)](https://gemnasium.com/7even/vkontakte_api) [![Code Climate](https://codeclimate.com/github/7even/vkontakte_api.png)](https://codeclimate.com/github/7even/vkontakte_api) [![Gitter](https://badges.gitter.im/gitterHQ/gitter.svg)](https://gitter.im/7even/vkontakte_api)

`vkontakte_api` is a ruby-adapter for VKontakte API. It allows you to call API methods, upload files to VKontakte servers and also supports 3 available authorization methods (while allowing to use third-party solutions).

## Installation

``` ruby
# Gemfile
gem 'vkontakte_api', '~> 1.4'
```

or simply

``` sh
$ gem install vkontakte_api
```

## Usage

### Calling API methods

``` ruby
# creating client
@vk = VkontakteApi::Client.new
# and calling API method
@vk.users.get(user_ids: 1)

# snake_case convention is a de-facto standard
# for method names in ruby
# so likes.getList becomes likes.get_list
@vk.likes.get_list
# names of methods that return '1' or '0'
# end with '?', and returned values
# are typecasted to true or false
@vk.is_app_user? # => false

# if some VKontakte method expects a list of parameters
# separated by commas, you can pass an array
users = @vk.users.get(user_ids: [1, 2, 3])

# most methods return a Hashie::Mash structure
# or an array of them
users.first.uid        # => 1
users.first.first_name # => "Павел"
users.first.last_name  # => "Дуров"

# when a method that returns an array is being called with a block
# then block will be executed for each element
# and the final result will be a processed array (like Enumerable#map)
fields = [:first_name, :last_name, :screen_name]
@vk.friends.get(user_id: 2, fields: fields) do |friend|
  "#{friend.first_name} '#{friend.screen_name}' #{friend.last_name}"
end
# => ["Павел 'durov' Дуров"]
```

### File upload

Files can be uploaded to VKontakte in several steps: first you need to call an API method that returns a URL to upload to; then upload the file(s) and in some cases call another finalization API method with uploaded file params. The API methods to call depend on the uploaded file type and are described in the [documentation](https://vk.com/dev/upload_files).

Files are transferred in a Hash format, where key is the name of the request parameter (described in documentation, for example `photo` when uploading photos), and the value is an array composed of 2 strings: full path to the file and it's MIME-type:

``` ruby
url = 'http://cs303110.vkontakte.ru/upload.php?act=do_add'
VkontakteApi.upload(url: url, photo: ['/path/to/file.jpg', 'image/jpeg'])
```

If the file was opened as an IO object, then it can be passed using alternative syntax &mdash; IO-object, MIME-type and the file path:

``` ruby
url = 'http://cs303110.vkontakte.ru/upload.php?act=do_add'
VkontakteApi.upload(url: url, photo: [file_io, 'image/jpeg', '/path/to/file.jpg'])
```

The `upload` method returns VKontakte server response converted to `Hashie::Mash`; it can be used when calling API method in the last step of upload process.

### Authorization

Most of methods require an access token to be called. To get this token, you can use authorization built in `vkontakte_api` or any other solution (for example [OmniAuth](https://github.com/intridea/omniauth)). In the latter case the result of authorization process is a token, which needs to be passed into `VkontakteApi::Client.new`.

VKontakte API provides 3 types of authorization: for webpages, for client applications (mobile or desktop, having access to authorized browsers) and special authorization type for servers to invoke administration methods without user authorization. More details are available [here](https://vk.com/dev/authentication); let's see how to use them with `vkontakte_api`.

For the purposes of authorization you have to specify `app_id` (application ID), `app_secret` (secret key) and `redirect_uri` (a URL where the user will be redirected after successful authorization) in the `VkontakteApi.configure` settings. For more information about configuring `vkontakte_api` see below.

##### Website

Website authorization goes in 2 steps. First user is redirected to VKontakte website to confirm the rights of a website to access his data. The list of available permissions is avaliable [here](https://vk.com/dev/permissions). Let's suppose one wants to access friends (`friends`) and photos (`photos`) of the user.

According to the [guidelines](http://tools.ietf.org/html/draft-ietf-oauth-v2-30#section-10.12) in OAuth2 protocol the `state` parameter should be passed with a random number in order to prevent [CSRF](http://ru.wikipedia.org/wiki/%D0%9F%D0%BE%D0%B4%D0%B4%D0%B5%D0%BB%D0%BA%D0%B0_%D0%BC%D0%B5%D0%B6%D1%81%D0%B0%D0%B9%D1%82%D0%BE%D0%B2%D1%8B%D1%85_%D0%B7%D0%B0%D0%BF%D1%80%D0%BE%D1%81%D0%BE%D0%B2).

``` ruby
session[:state] = Digest::MD5.hexdigest(rand.to_s)
redirect_to VkontakteApi.authorization_url(scope: [:notify, :friends, :photos], state: session[:state])
```

After successful authorization the user is redirected to `redirect_uri` and the parameters will contain the code that can be used to obtain an access token, as well as the `state`. When `state` differs from the one used in the first step there is a high probability of CSRF-attack &mdash; the user should be forced to begin the authorization process from the beginning.

``` ruby
redirect_to login_url, alert: 'Authorization error' if params[:state] != session[:state]
```

`vkontakte_api` provides a `VkontakteApi.authorize` method which makes a request to VKontakte with a given code, gets a token and creates a client:

``` ruby
@vk = VkontakteApi.authorize(code: params[:code])
# now API methods can be called on @vk object
@vk.is_app_user?
```

Client will contain the id of the user who authorized the application; it can be obtained using the `VkontakteApi::Client#user_id` method:

``` ruby
@vk.user_id # => 123456
```

It's also helpful to keep the obtained token at this point (and the user id if necessary) in the DB or in session so they can be used again in the future:

``` ruby
current_user.token = @vk.token
current_user.vk_id = @vk.user_id
current_user.save
# later
@vk = VkontakteApi::Client.new(current_user.token)
```

##### Client application

Client application authorization is much easier: you don't need a separate request to obtain the token &mdash; it's returned right after the user is redirected back to the application.

``` ruby
# user is redirected to the following URL
VkontakteApi.authorization_url(type: :client, scope: [:friends, :photos])
```

You should note that `redirect_uri` must be assigned to `http://api.vkontakte.ru/blank.html`, otherwise it won't be possible to call methods available to client applications.

After user confirms his access rights he will be redirected to `redirect_uri` with the `access_token` parameter containing the token that should be passed to `VkontakteApi::Client.new`.

##### Application server

The last type of authorization is the easiest one since it does not require any user involvement.

``` ruby
@vk = VkontakteApi.authorize(type: :app_server)
```

### Other

If the API client (instance of `VkontakteApi::Client`) was created by calling `VkontakteApi.authorize` method, it will contain the information about current user id (`user_id`) and about expiry time of token (`expires_at`). You can check it using these methods:

``` ruby
vk = VkontakteApi.authorize(code: 'c1493e81f69fce1b43')
# => #<VkontakteApi::Client:0x007fa578f00ad0>
vk.user_id    # => 628985
vk.expires_at # => 2012-12-18 23:22:55 +0400
# VkontakteApi::Client#expired can be used to check if the token has expired
vk.expired?   # => false
```

You can also get the list of access rights given by this token, in the form similar to the form of `scope` parameter in authorization process:

``` ruby
vk.scope # => [:friends, :groups]
```

It uses the `getUserSettings` API method with the result cached after the first call.

To create a `VK` alias for `VkontakteApi` module just call `VkontakteApi.register_alias`:

``` ruby
VkontakteApi.register_alias
VK::Client.new # => #<VkontakteApi::Client:0x007fa578d6d948>
```

This alias can be removed with `VkontakteApi.unregister_alias`:

``` ruby
VK.unregister_alias
VK # => NameError: uninitialized constant VK
```

### Error handling

When VKontakte API returns an error, a `VkontakteApi::Error` exception is raised.

``` ruby
vk = VK::Client.new
vk.friends.get(user_id: 1, fields: [:first_name, :last_name, :photo])
# VkontakteApi::Error: VKontakte returned an error 7: 'Permission to perform this action is denied' after calling method 'friends.get' with parameters {"user_id"=>"1", "fields"=>"first_name,last_name,photo"}.
```

There is special case of errors &mdash; 14: the user has to enter a captcha code.
In this case captcha parameters can be obtained using `VkontakteApi::Error#captcha_sid` method
and `VkontakteApi::Error#captcha_img` &mdash; for example,
[like this](https://github.com/7even/vkontakte_api/issues/10#issuecomment-11666091).

### Logging

`vkontakte_api` logs information about requests when calling methods.
By default they are all written in `STDOUT` but you can choose any
other data logger, `Rails.logger` for example.

It is possible to log 3 types of information,
and each one has a corresponding key in the global settings.

|                          | setting key     | default value | message level |
| ------------------------ | --------------- | ------------- | ------------- |
| request URL              | `log_requests`  | `true`        | `debug`       |
| JSON response of error   | `log_errors`    | `true`        | `warn`        |
| JSON successful response | `log_responses` | `false`       | `debug`       |

In Rails application with default settings in production only server responses
with errors are being saved; in development there are also logged URL addresses of requests.

### Example

An example of using `vkontakte_api` together with `eventmachine` can be seen
[here](https://github.com/7even/vkontakte_on_em).

[An example with rails](https://github.com/7even/vkontakte_on_rails) also
exists, but it no longer works due to the lack of access rights to call
the `newsfeed.get` method from websites.

## Settings

Global parameters of `vkontakte_api` should be set in `VkontakteApi.configure` block as follows:

``` ruby
VkontakteApi.configure do |config|
  # parameters required for authorization with vkontakte_api
  # (not needed when using a third-party authorization solution)
  config.app_id       = '123'
  config.app_secret   = 'AbCdE654'
  config.redirect_uri = 'http://example.com/oauth/callback'

  # faraday adapter for network requests
  config.adapter = :net_http
  # HTTP method for calling API methods (:get or :post)
  config.http_verb = :post
  # parameters for faraday connection
  config.faraday_options = {
    ssl: {
      ca_path:  '/usr/lib/ssl/certs'
    },
    proxy: {
      uri:      'http://proxy.example.com',
      user:     'foo',
      password: 'bar'
    }
  }

  # maximum number of retries after an error
  # works only when using http_verb :get
  config.max_retries = 2

  # logger
  config.logger        = Rails.logger
  config.log_requests  = true  # request URLs
  config.log_errors    = true  # errors
  config.log_responses = false # successful responses

  # API version
  config.api_version = '5.21'
end
```

By default the `Net::HTTP` Faraday adapter is used but you can choose
[any other adapter](https://github.com/lostisland/faraday/blob/master/lib/faraday/adapter.rb)
supported by `faraday`.

VKontakte [allows](https://vk.com/dev/api_requests)
using either `GET` or `POST` requests when calling API methods.
`vkontakte_api` uses `POST` by default but you can change that by
setting `http_verb` to `:get`.

You can specify custom parameters for faraday-connection if necessary &mdash;
parameters of a proxy server or a path to SSL certificates for example.

In order to use a specific API version in every method call you can specify it
in the `api_version` key of configuration. By default it is not set.

To generate a file with default settings in Rails application
you can use the `vkontakte_api:install` generator:

``` sh
$ cd /path/to/app
$ rails generate vkontakte_api:install
```

## JSON parser

`vkontakte_api` uses the [Oj](https://github.com/ohler55/oj) parser &mdash; it is
the only parser that has not thrown any [errors](https://github.com/7even/vkontakte_api/issues/1)
while parsing JSON generated by VKontakte API.

Oj has the top priority in `multi_json` library (a wrapper for different
JSON parsers which selects the fastest parser installed on the system and uses it)
so when `Oj` is present in your bundle it will also be used by MultiJSON.

## Roadmap

* CLI-interface with automatic authorization

## Development

If you want to participate in the vkontakte_api development fork
the repository, create changes on separate branch, cover them with specs
and create a pull request.

`vkontakte_api` is tested under MRI `1.9.3`, `2.0.0` and `2.1.2`.
If it is not working properly in any of these versions it should be considered
a bug and reported to [issues on Github](https://github.com/7even/vkontakte_api/issues).
