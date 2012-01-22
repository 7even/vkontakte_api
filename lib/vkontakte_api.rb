require 'active_support/core_ext/string/inflections'

require 'vkontakte_api/version'
require 'vkontakte_api/configuration'
require 'vkontakte_api/client'

module VkontakteApi
  extend VkontakteApi::Configuration
end

# short alias
VK = VkontakteApi
