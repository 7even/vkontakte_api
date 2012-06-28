module VkontakteApi
  module Resolvable
    attr_reader :name
    
    def initialize(name, options = {})
      @name     = name
      @resolver = options.delete(:resolver)
    end
    
    def token
      @resolver.token
    end
  end
end
