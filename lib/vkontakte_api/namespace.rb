module VkontakteApi
  # An API method namespace (such as `users` or `friends`). It just includes `Resolvable` and `Resolver`.
  class Namespace
    include Resolvable
    include Resolver
    
    # Creates and calls the `VkontakteApi::Method` using `VkontakteApi::Resolver#call_method`.
    def method_missing(*args, &block)
      call_method(args, &block)
    end
  end
end
