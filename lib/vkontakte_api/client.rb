module VkontakteApi
  # A class representing a connection to VK. It holds an access token.
  class Client
    # include Resolver
    
    # An access token needed by authorized requests.
    attr_reader :access_token
    
    # A new API client.
    # @param [String] access_token An access token.
    def initialize(access_token = nil)
      @access_token = access_token
    end
    
    # Is a `VkontakteApi::Client` instance authorized.
    def authorized?
      !@access_token.nil?
    end
    
    # All unknown methods are delegated to a `VkontakteApi::Resolver` instance.
    def method_missing(method_name, *args, &block)
      args = args.first || {}
      VkontakteApi::Resolver.new(:access_token => @access_token).send(method_name, args, &block)
    end
  end
end
