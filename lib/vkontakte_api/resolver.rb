module VkontakteApi
  # A mixin for classes that will resolve other classes' objects via `#method_missing`.
  module Resolver
    # Main methods dispatch.
    # 
    # If the called method is a namespace, it creates and returns a new `VkontakteApi::Namespace` instance.
    # Otherwise it creates a `VkontakteApi::Method` instance and invokes it's `#call` method passing it the arguments and a block.
    def method_missing(*args, &block)
      if Resolver.namespaces.include?(args.first.to_s)
        # creating a Namespace from Client
        create_namespace(args.first)
      else
        # calling one-level method
        call_method(args, &block)
      end
    end
    
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
      # An array of method namespaces.
      # Lazily loads the list from `namespaces.yml` and caches it.
      # @return [Array]
      def namespaces
        if @namespaces.nil?
          filename    = File.expand_path('../namespaces.yml', __FILE__)
          @namespaces = YAML.load_file(filename)
        end
        
        @namespaces
      end
      
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
