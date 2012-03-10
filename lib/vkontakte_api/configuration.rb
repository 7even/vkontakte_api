module VkontakteApi
  # General configuration module.
  # 
  # It extends `VkontakteApi` so it's methods should be called from there.
  module Configuration
    # Available options.
    OPTION_NAMES = [:app_id, :app_secret, :adapter]
    
    attr_accessor *OPTION_NAMES
    
    # Default HTTP adapter.
    DEFAULT_ADAPTER = :net_http
    
    # A global configuration set via the block.
    # @example
    #   VkontakteApi.configure do |config|
    #     config.adapter = :net_http
    #   end
    def configure
      yield self if block_given?
      self
    end
    
    # Reset all configuration options to defaults.
    def reset
      @adapter = DEFAULT_ADAPTER
    end
    
    # When this module is extended, set all configuration options to their default values.
    def self.extended(base)
      base.reset
    end
  end
end
