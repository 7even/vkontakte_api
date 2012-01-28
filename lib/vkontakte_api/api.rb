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
        response = JSON.load(body)
        
        if response.has_key?('error')
          raise VkontakteApi::Error.new(response['error'])
        else
          response['response']
        end
      end
    private
      def url_for(method_name, args)
        arg_pairs = args.map { |(k, v)| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
        "#{BASE_URL}#{CGI.escape(method_name)}?#{arg_pairs}"
      end
    end
  end
end
