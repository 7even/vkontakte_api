module VkontakteApi
  # A mixin for classes that will resolve other classes' objects via `#method_missing`.
  module Resolver
    # Main methods dispatch.
    # 
    # If the called method is a namespace, it creates and returns a new `VkontakteApi::Namespace` instance.
    # Otherwise it creates a `VkontakteApi::Method` instance and invokes it's `#call` method passing it the arguments and a block.
    def method_missing(method_name, *args, &block)
      method_name = method_name.to_s
      
      if Resolver.namespaces.include?(method_name)
        # called from Client
        Namespace.new(method_name, :resolver => resolver)
      else
        # called from Namespace or one-level method
        Method.new(method_name, :resolver => resolver).call(args.first || {}, &block)
      end
    end
    
    # A `Hashie::Mash` structure holding the name and token of current instance.
    # @return [Hashie::Mash]
    def resolver
      @resolver ||= Hashie::Mash.new(:name => @name, :token => token)
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
    end
  end
end
