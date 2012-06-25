require 'oj'
Oj.mimic_JSON

require 'faraday'
require 'faraday_middleware'
require 'yaml'
require 'hashie'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/to_query'

require 'vkontakte_api/version'
require 'vkontakte_api/error'
require 'vkontakte_api/configuration'
require 'vkontakte_api/api'
require 'vkontakte_api/resolver'
require 'vkontakte_api/client'
require 'vkontakte_api/logger'

# Main module.
module VkontakteApi
  extend VkontakteApi::Configuration
end

# short alias
VK = VkontakteApi unless defined?(VK)
