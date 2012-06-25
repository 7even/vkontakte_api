module VkontakteApi
  # Faraday middleware for logging requests and responses.
  class Logger < Faraday::Response::Middleware
    def initialize(app)
      super(app)
      @logger = VkontakteApi.logger
    end
    
    # Logs the request if needed.
    def call(env)
      if VkontakteApi.log_requests?
        @logger.debug "#{env[:method].to_s.upcase} #{env[:url].to_s}"
      end
      
      super
    end
    
    # Logs the response (successful or not) if needed.
    def on_complete(env)
      if env[:body].has_key?('error')
        @logger.warn env[:raw_body]  if VkontakteApi.log_errors?
      else
        @logger.debug env[:raw_body] if VkontakteApi.log_responses?
      end
    end
  end
end

Faraday.register_middleware :response, :vk_logger => VkontakteApi::Logger
