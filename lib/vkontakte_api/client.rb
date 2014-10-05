module VkontakteApi
  # A class representing a connection to VK. It holds the access token.
  class Client
    include Resolver
    
    # Access rights and their respective number representation.
    SCOPE = {
      notify:        1,
      friends:       2,
      photos:        4,
      audio:         8,
      video:         16,
      offers:        32,
      questions:     64,
      pages:         128,
      status:        1024,
      notes:         2048,
      messages:      4096,
      wall:          8192,
      ads:           32768,
      docs:          131072,
      groups:        262144,
      notifications: 524288,
      stats:         1048576
    }
    
    # An access token needed by authorized requests.
    # @return [String]
    attr_reader :token
    
    # Current user id.
    # @return [Integer]
    attr_reader :user_id
    
    # Current user email.
    # @return [String]
    attr_reader :email
    
    # Token expiration time
    # @return [Time]
    attr_reader :expires_at
    
    # A new API client.
    # If given an `OAuth2::AccessToken` instance, it extracts and keeps
    # the token string, the user id and the expiration time;
    # otherwise it just stores the given token.
    # @param [String, OAuth2::AccessToken] token An access token.
    def initialize(token = nil)
      if token.respond_to?(:token) && token.respond_to?(:params)
        # token is an OAuth2::AccessToken
        @token      = token.token
        @user_id    = token.params['user_id']
        @email      = token.params['email']
        @expires_at = Time.at(token.expires_at) unless token.expires_at.nil?
      else
        # token is a String or nil
        @token = token
      end
    end
    
    # Is a `VkontakteApi::Client` instance authorized.
    def authorized?
      !@token.nil?
    end
    
    # Did the token already expire.
    def expired?
      @expires_at && @expires_at < Time.now
    end
    
    # Access rights of this token.
    # @return [Array] An array of symbols representing the access rights.
    def scope
      SCOPE.reject do |access_scope, mask|
        (settings & mask).zero?
      end.keys
    end
    
    # Called without arguments it returns the `execute` namespace;
    # called with arguments it calls the top-level `execute` API method.
    def execute(*args)
      if args.empty?
        create_namespace(:execute)
      else
        call_method([:execute, *args])
      end
    end
    
    # If the called method is a namespace, it creates and returns a new `VkontakteApi::Namespace` instance.
    # Otherwise it creates a `VkontakteApi::Method` instance and calls it passing the arguments and a block.
    def method_missing(*args, &block)
      if Namespace.exists?(args.first)
        create_namespace(args.first)
      else
        call_method(args, &block)
      end
    end
    
  private
    def settings
      @settings ||= self.get_user_settings
    end
  end
end
