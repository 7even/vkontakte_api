module VkontakteApi
  # A mixin for classes that will resolve other classes' objects via `#method_missing`.
  module Resolver
    # A `Hashie::Mash` structure holding the name and token of current instance.
    # @return [Hashie::Mash]
    def resolver
      @resolver ||= Hashie::Mash.new(name: @name, token: token)
    end
    
  private
    def create_namespace(name)
      Namespace.new(name, resolver: resolver)
    end
    
    def create_method(name)
      Method.new(name, resolver: resolver)
    end
    
    def call_method(args, &block)
      create_method(args.shift).call(args.first || {}, &block)
    end
    
    class << self
      # When this module is included, it undefines the `:send` instance method in the `base_class`
      # so it can be resolved via `method_missing`.
      def included(base_class)
        base_class.class_eval do
          undef_method :send
        end
      end
    end
  end
end
