module VkontakteApi
  # An API method namespace (such as `users` or `friends`). It just includes `Resolvable` and `Resolver`.
  class Namespace
    include Resolvable
    include Resolver
  end
end
