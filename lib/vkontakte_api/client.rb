module VkontakteApi
  class Client
    attr_reader :access_token
    
    def initialize(access_token = nil)
      @access_token = access_token
    end
    
    def authorized?
      !@access_token.nil?
    end
  end
end
