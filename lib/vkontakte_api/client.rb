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
      name = self.class.vk_method_name(method_name)
      api_call(name)
    end
    
    class << self
      def vk_method_name(method_name)
        method_name.to_s.camelize(:lower)
      end
    end
  end
end
