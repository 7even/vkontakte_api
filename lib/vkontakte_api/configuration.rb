module VkontakteApi
  module Configuration
    OPTION_NAMES = [:app_id, :app_secret]
    
    attr_accessor *OPTION_NAMES
    
    def configure
      yield self if block_given?
      self
    end
  end
end
