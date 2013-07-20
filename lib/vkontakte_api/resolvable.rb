module VkontakteApi
  # A mixin for classes that will be resolved via `#method_missing`.
  module Resolvable
    attr_reader :name
    
    # Creates a resolvable object keeping it's name and the object that resolved it.
    # @param [String] name The name of this resolvable.
    # @option options [Hashie::Mash] :resolver A mash holding information about the previous resolver.
    def initialize(name, options = {})
      @name = name.to_s
      @previous_resolver = options.delete(:resolver)
    end
    
    # Returns the token from the previous resolver.
    # @return [String] A token.
    def token
      @previous_resolver.token
    end
  end
end
