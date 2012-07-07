module VkontakteApi
  # A class representing a connection to VK. It holds the access token.
  class Client
    include Resolver
    
    # An access token needed by authorized requests.
    attr_reader :token
    
    # A new API client.
    # @param [String, OAuth2::AccessToken] token An access token.
    def initialize(token = nil)
      if token.respond_to?(:token)
        # token is an OAuth2::AccessToken
        @token = token.token
      else
        # token is a String or nil
        @token = token
      end
    end
    
    # Is a `VkontakteApi::Client` instance authorized.
    def authorized?
      !@token.nil?
    end
  end
end
