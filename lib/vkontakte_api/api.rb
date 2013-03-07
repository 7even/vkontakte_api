module VkontakteApi
  # A low-level module which handles the requests to VKontakte API and returns their results as mashes.
  # 
  # It uses Faraday with middleware underneath the hood.
  module API
    # URL prefix for calling API methods.
    URL_PREFIX = 'https://api.vk.com/method'
    
    class << self
      # API method call.
      # @param [String] method_name A full name of the method.
      # @param [Hash] args Method arguments.
      # @param [String] token The access token.
      # @return [Hashie::Mash] Mashed server response.
      def call(method_name, args = {}, token = nil)
        flat_arguments = Utils.flatten_arguments(args)
        connection(url: URL_PREFIX, token: token).send(VkontakteApi.http_verb, method_name, flat_arguments).body
      end
      
      # Faraday connection.
      # @param [Hash] options Connection options.
      # @option options [String] :url Connection URL (either full or just prefix).
      # @option options [String] :token OAuth2 access token (not used if omitted).
      # @return [Faraday::Connection] Created connection.
      def connection(options = {})
        url   = options.delete(:url)
        token = options.delete(:token)
        
        Faraday.new(url, VkontakteApi.faraday_options) do |builder|
          builder.request  :oauth2, token unless token.nil?
          builder.request  :multipart
          builder.request  :url_encoded
          builder.response :vk_logger
          builder.response :mashify
          builder.response :oj, preserve_raw: true
          builder.adapter  VkontakteApi.adapter
        end
      end
    end
  end
end
