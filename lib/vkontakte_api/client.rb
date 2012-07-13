module VkontakteApi
  # A class representing a connection to VK. It holds the access token.
  class Client
    include Resolver
    
    # An access token needed by authorized requests.
    # @return [String]
    attr_reader :token
    # Current user id.
    # @return [Integer]
    attr_reader :user_id
    
    # A new API client.
    # If given an `OAuth2::AccessToken` instance, it extracts and keeps
    # the token string and the user id; otherwise it just stores the given token.
    # @param [String, OAuth2::AccessToken] token An access token.
    def initialize(token = nil)
      if token.respond_to?(:token) && token.respond_to?(:params)
        # token is an OAuth2::AccessToken
        @token   = token.token
        @user_id = token.params['user_id']
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
