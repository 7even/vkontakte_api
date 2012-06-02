require 'logger'

module VkontakteApi
  # General configuration module.
  # 
  # It extends `VkontakteApi` so it's methods should be called from there.
  module Configuration
    # Available options.
    OPTION_NAMES = [:app_id, :app_secret, :adapter, :logger, :log_errors, :log_responses]
    
    attr_accessor *OPTION_NAMES
    
    alias_method :log_errors?, :log_errors
    alias_method :log_responses?, :log_responses
    
    # Default HTTP adapter.
    DEFAULT_ADAPTER = :net_http
    
    # Logger default options.
    DEFAULT_LOGGER_OPTIONS = {
      :errors    => true,
      :responses => false
    }
    
    # A global configuration set via the block.
    # @example
    #   VkontakteApi.configure do |config|
    #     config.adapter       = :net_http
    #     config.logger        = Rails.logger
    #     config.log_errors    = true
    #     config.log_responses = false
    #   end
    def configure
      yield self if block_given?
      self
    end
    
    # Reset all configuration options to defaults.
    def reset
      @adapter       = DEFAULT_ADAPTER
      @logger        = Logger.new(STDOUT)
      @log_errors    = DEFAULT_LOGGER_OPTIONS[:errors]
      @log_responses = DEFAULT_LOGGER_OPTIONS[:responses]
    end
    
    # When this module is extended, set all configuration options to their default values.
    def self.extended(base)
      base.reset
    end
  end
end
