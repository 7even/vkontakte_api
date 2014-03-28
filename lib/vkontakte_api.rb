require 'faraday'
require 'oauth2'
require 'yaml'
require 'hashie'

require 'vkontakte_api/version'
require 'vkontakte_api/error'
require 'vkontakte_api/configuration'
require 'vkontakte_api/authorization'
require 'vkontakte_api/uploading'
require 'vkontakte_api/utils'
require 'vkontakte_api/api'
require 'vkontakte_api/resolver'
require 'vkontakte_api/resolvable'
require 'vkontakte_api/client'
require 'vkontakte_api/namespace'
require 'vkontakte_api/method'
require 'vkontakte_api/result'
require 'vkontakte_api/response/logger'
require 'vkontakte_api/response/mashify'
require 'vkontakte_api/response/parse_oj'
require 'vkontakte_api/request/oauth2'

# Main module.
module VkontakteApi
  extend VkontakteApi::Configuration
  extend VkontakteApi::Authorization
  extend VkontakteApi::Uploading

  class << self
    # Creates a short alias `VK` for `VkontakteApi` module.
    def register_alias
      Object.const_set(:VK, VkontakteApi)
    end
    
    # Removes the `VK` alias.
    def unregister_alias
      Object.send(:remove_const, :VK) if defined?(VK)
    end
  end
end
