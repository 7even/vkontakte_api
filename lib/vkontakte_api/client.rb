module VkontakteApi
  class Client
    attr_reader :access_token
    
    def initialize(access_token = nil)
      @access_token = access_token
    end
    
    def authorized?
      !@access_token.nil?
    end
    
    def method_missing(method_name, *args, &block)
      args = args.first || {}
      VkontakteApi::Resolver.new(:access_token => @access_token).send(method_name, args, &block)
    end
  end
end
