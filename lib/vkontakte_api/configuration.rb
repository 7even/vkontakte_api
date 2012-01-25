module VkontakteApi
  module Configuration
    OPTION_NAMES = [:app_id, :app_secret, :adapter]
    
    attr_accessor *OPTION_NAMES
    
    DEFAULT_ADAPTER = :net_http
    
    def configure
      yield self if block_given?
      self
    end
    
    def reset
      @adapter = DEFAULT_ADAPTER
    end
    
    def self.extended(base)
      base.reset
    end
  end
end
