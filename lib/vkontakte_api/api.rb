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
      def url_for(method_name, args)
        "#{BASE_URL}#{method_name}?#{args.to_param}"
      end
    end
  end
end
