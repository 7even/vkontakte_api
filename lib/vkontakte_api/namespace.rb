module VkontakteApi
  # An API method namespace (such as `users` or `friends`).
  #
  # It includes `Resolvable` and `Resolver` and calls API methods via `Resolver#call_method`.
  # It also holds the list of all known namespaces.
  class Namespace
    include Resolvable
    include Resolver
    
    # Creates and calls the `VkontakteApi::Method` using `VkontakteApi::Resolver#call_method`.
    def method_missing(*args, &block)
      call_method(args, &block)
    end
    
    class << self
      # An array of all method namespaces.
      #
      # Lazily loads the list from `namespaces.yml` and caches it.
      # @return [Array] An array of strings
      def names
        if @names.nil?
          filename = File.expand_path('../namespaces.yml', __FILE__)
          @names   = YAML.load_file(filename)
        end
        
        @names
      end
      
      # Does a given namespace exist?
      # @param [String, Symbol] name
      def exists?(name)
        names.include?(name.to_s)
      end
    end
  end
end
