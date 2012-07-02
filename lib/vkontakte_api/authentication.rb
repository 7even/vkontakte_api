module VkontakteApi
  module Authentication
    OPTIONS = {
      :client => {
        :site          => 'https://oauth.vk.com',
        :authorize_url => '/authorize',
        :token_url     => '/access_token'
      },
      :client_credentials => {
        'auth_scheme' => 'request_body'
      }
    }
    
    def authentication_url(options = {})
      type = options.delete(:type) || :site
      # redirect_uri passed in options overrides the global setting
      options[:redirect_uri] ||= VkontakteApi.redirect_uri
      options[:scope] = VkontakteApi::Utils.flatten_argument(options[:scope]) if options[:scope]
      
      case type
      when :site
        client.auth_code.authorize_url(options)
      when :client
        client.implicit.authorize_url(options)
      else
        raise ArgumentError, "Unknown authentication type #{type.inspect}"
      end
    end
    
    def authenticate(options = {})
      type = options.delete(:type) || :site
      
      case type
      when :site
        code  = options.delete(:code)
        token = client.auth_code.get_token(code)
      when :app_server
        token = client.client_credentials.get_token({}, OPTIONS[:client_credentials])
      else
        raise ArgumentError, "Unknown authentication type #{type.inspect}"
      end
      
      Client.new(token)
    end
    
  private
    def client
      @client ||= OAuth2::Client.new(VkontakteApi.app_id, VkontakteApi.app_secret, OPTIONS[:client])
    end
  end
end
