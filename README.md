# vkontakte_api

`vkontakte_api` is a Ruby wrapper for VKontakte API. It allows you to call all documented and working methods in the simplest possible way.

## Installation

``` bash
gem install vkontakte_api
```

## Usage

``` ruby
require 'vkontakte_api'

# app credentials configuration
VK.configure do |config|
  config.app_id = '123456'
  config.app_secret = 'my_secret_hash'
end

# creating an authenticated API client with an access token
@app = VK::Client.new('my_access_token')

# and calling some methods
@app.is_app_user? # => true
@app.friends.get  # => [1, 6492]

@app.friends.get(fields: 'uid,first_name,last_name')
# => [
  {
    "uid":        "1",
    "first_name": "Павел",
    "last_name":  "Дуров"
  },
  {
    "uid":        "6492",
    "first_name": "Andrew",
    "last_name":  "Rogozov"
  }
]

# if the response is an array, you can pass a block
# that will yield each successive element
@app.friends.get(fields: 'first_name') do |friend|
  "#{friend.first_name} #{friend.last_name}"
end
# => ["Павел Дуров", "Andrew Rogozov"]
```

All method names are underscore_cased as opposed to the official documentation where they are camelCased. All parameters are named and passed to methods in symbol-indexed hashes (see example above).
