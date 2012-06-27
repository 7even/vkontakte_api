module VkontakteApi
  class Method
    include Resolvable
    
    attr_reader :namespace
    
    def initialize(name, options = {})
      super
      @namespace = options.delete(:namespace)
    end
  end
end
