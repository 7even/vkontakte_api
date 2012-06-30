module VkontakteApi
  module Resolvable
    attr_reader :name
    
    def initialize(name, options = {})
      @name = name
      @previous_resolver = options.delete(:resolver)
    end
    
    def token
      @previous_resolver.token
    end
  end
end
