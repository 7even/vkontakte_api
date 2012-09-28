module VkontakteApi
  # A module containing the methods for authorization.
  # 
  # @note `VkontakteApi::Authorization` extends `VkontakteApi` so these methods should be called from the latter.
  module Authorization
    # Authorization options.
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
    
    # URL for redirecting the user to VK where he gives the application all the requested access rights.
    # @option options [Symbol] :type The type of authorization being used (`:site` and `:client` supported).
    # @option options [String] :redirect_uri URL for redirecting the user back to the application (overrides the global configuration value).
    # @option options [Array] :scope An array of requested access rights (each represented by a symbol or a string).
    # @raise [ArgumentError] raises after receiving an unknown authorization type.
    # @return [String] URL to redirect the user to.
    def authorization_url(options = {})
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
        raise ArgumentError, "Unknown authorization type #{type.inspect}"
      end
    end
    
    # Authorization (getting the access token and building a `VkontakteApi::Client` with it).
    # @option options [Symbol] :type The type of authorization being used (`:site` and `:app_server` supported).
    # @option options [String] :code The code to exchange for an access token (for `:site` authorization type). 
    # @raise [ArgumentError] raises after receiving an unknown authorization type.
    # @return [VkontakteApi::Client] An API client.
    def authorize(options = {})
      type = options.delete(:type) || :site
      
      options[:redirect_uri] ||= VkontakteApi.redirect_uri
      
      case type
      when :site
        code  = options.delete(:code)
        token = client.auth_code.get_token(code, options)
      when :app_server
        token = client.client_credentials.get_token(options, OPTIONS[:client_credentials])
      else
        raise ArgumentError, "Unknown authorization type #{type.inspect}"
      end
      
      Client.new(token)
    end
    
  private
    def client
      @client ||= OAuth2::Client.new(VkontakteApi.app_id, VkontakteApi.app_secret, OPTIONS[:client])
    end
  end
end
