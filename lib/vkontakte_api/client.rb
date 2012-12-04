module VkontakteApi
  SCOPE = {
    :notify         => 1,
    :friends        => 2,
    :photos         => 4,
    :audio          => 8,
    :video          => 16,
    :offers         => 32,
    :questions      => 64,
    :pages          => 128,
    :status         => 1024,
    :notes          => 2048,
    :messages       => 4096,
    :wall           => 8192,
    # :offline        => 16384,
    :ads            => 32768,
    :docs           => 131072,
    :groups         => 262144,
    :notifications  => 524288,
    :stats          => 1048576
  }
  
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
    
    def scope
      SCOPE.inject([]) do |array, (access_scope, mask)|
        array << access_scope unless (settings & mask).zero?
        array
      end
    end
    
  private
    def settings
      @settings ||= self.get_user_settings
    end
  end
end
