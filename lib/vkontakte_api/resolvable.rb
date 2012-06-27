module VkontakteApi
  module Resolvable
    attr_reader :name, :token
    
    def initialize(name, options = {})
      @name  = name
      @token = options.delete(:token)
    end
  end
end
