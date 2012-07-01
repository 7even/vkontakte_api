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
      strategy = options.delete(:strategy) || :auth_code
      # redirect_uri passed in options overrides the global setting
      options[:redirect_uri] ||= VkontakteApi.redirect_uri
      options[:scope] = VkontakteApi::Utils.flatten_argument(options[:scope]) if options[:scope]
      
      client.auth_code.authorize_url(options)
    end
    
    def authenticate(options = {})
      strategy = options.delete(:strategy) || :auth_code
      code     = options.delete(:code)
      
      case strategy
      when :auth_code
        token = client.auth_code.get_token(code)
      when :client_credentials
        token = client.client_credentials.get_token({}, OPTIONS[:client_credentials])
      else
        raise ArgumentError, "Unknown strategy #{strategy.inspect}"
      end
      
      Client.new(token)
    end
    
  private
    def client
      @client ||= OAuth2::Client.new(VkontakteApi.app_id, VkontakteApi.app_secret, OPTIONS[:client])
    end
  end
end
