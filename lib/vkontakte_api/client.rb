module VkontakteApi
  # A class representing a connection to VK. It holds an access token.
  class Client
    include Resolver
    
    # An access token needed by authorized requests.
    attr_reader :token
    
    # A new API client.
    # @param [String] token An access token.
    def initialize(token = nil)
      @token = token
    end
    
    # Is a `VkontakteApi::Client` instance authorized.
    def authorized?
      !@token.nil?
    end
  end
end
