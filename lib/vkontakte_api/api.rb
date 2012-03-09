module VkontakteApi
  module API
    BASE_HOST = 'https://api.vkontakte.ru'
    BASE_URL  = '/method/'
    
    class << self
      def call(method_name, args = {}, &block)
        connection = Faraday.new(:url => BASE_HOST) do |builder|
          builder.adapter(VkontakteApi.adapter)
        end
        
        url = url_for(method_name, args)
        body = connection.get(url).body
        response = Yajl::Parser.parse(body, :symbolize_keys => true)
        
        if response.has_key?(:error)
          raise VkontakteApi::Error.new(response[:error])
        else
          response[:response]
        end
      end
      
    private
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
