module VkontakteApi
  # A low-level module which handles the requests to VKontakte and returns their results as hashes with symbolized keys.
  # 
  # It uses Faraday underneath the hood.
  module API
    BASE_HOST = 'https://api.vkontakte.ru'
    BASE_URL  = '/method/'
    
    class << self
      # Main interface method.
      # @param [String] method_name A full name of the method.
      # @param [Hash] args Method arguments including the access token.
      # @return [Hash] The result of the method call.
      # @raise [VkontakteApi::Error] raised when VKontakte returns an error.
      def call(method_name, args = {}, &block)
        url = url_for(method_name, args)
        response = connection.get(url).body
        response = Hashie::Mash.new(response)
        
        if response.error?
          VkontakteApi.logger.warn(response) if VkontakteApi.log_errors?
          raise VkontakteApi::Error.new(response.error)
        else
          VkontakteApi.logger.debug(response) if VkontakteApi.log_responses?
          response.response
        end
      end
      
    private
      def connection
        Faraday.new(:url => BASE_HOST) do |builder|
          builder.response :json
          builder.adapter  VkontakteApi.adapter
        end
      end
      
      def url_for(method_name, arguments)
        flat_arguments = flatten_arguments(arguments)
        "#{BASE_URL}#{method_name}?#{flat_arguments.to_param}"
      end
      
      def flatten_arguments(arguments)
        arguments.inject({}) do |flat_args, (arg_name, arg_value)|
          flat_args[arg_name] = if arg_value.respond_to?(:join)
            # if value is an array, we join it with a comma
            arg_value.join(',')
          else
            # otherwise leave it untouched
            arg_value
          end
          
          flat_args
        end
      end
    end
  end
end
