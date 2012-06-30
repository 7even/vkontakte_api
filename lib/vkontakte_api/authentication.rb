module VkontakteApi
  module Authentication
    URLS = {
      :authorize_url => 'https://oauth.vk.com/authorize'
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
      
      token = client.auth_code.get_token(code)
      Client.new(token)
    end
    
  private
    def client
      @client ||= OAuth2::Client.new(VkontakteApi.app_id, VkontakteApi.app_secret, :site => URLS[:authorize_url])
    end
  end
end
