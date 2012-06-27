module VkontakteApi
  # A class for resolving namespaced methods like `friends.get`.
  # 
  # Methods are dispatched the following way:
  # 
  # 1. API client gets an unknown method, creates a `VkontakteApi::Resolver` instance and sends it the method
  # 2. if the method is a namespace (like `friends`), it creates another `VkontakteApi::Resolver` instance, namespaced this time; else go to 3
  # 3. the `VkontakteApi::Resolver` instance gets the last method, inserts an access token into params and sends it to `VkontakteApi::API`
  # 4. the result is typecasted and/or yielded (mapped) to a block depending on it's type
  class Resolver
    # A pattern for names of methods with a boolean result.
    PREDICATE_NAMES = /^is.*\?$/
    
    # A namespace of the current instance (if present).
    attr_reader :namespace
    
    # A new resolver.
    # @option options [String] :namespace A namespace.
    # @option options [String] :access_token An access token.
    def initialize(options = {})
      @namespace    = options.delete(:namespace)
      @access_token = options.delete(:access_token)
    end
    
    # Main methods dispatch.
    # 
    # If the called method is a namespace, it creates and returns a new `VkontakteApi::Resolver` instance.
    # Otherwise it determines the full method name and result type, and sends everything to `VkontakteApi::API`.
    # 
    # If the result is enumerable, each element is yielded to the block (or returned as is if called without a block).
    # Non-enumerable results are typecasted (and yielded if the block is present).
    # 
    # Called with a block, it returns the result of the block; called without a block it returns just the result.
    # @todo Break this crap into several small methods.
    def method_missing(method_name, *args, &block)
      method_name = method_name.to_s
      
      if Resolver.namespaces.include?(method_name)
        # method_name is a name of some namespace
        Resolver.new(:namespace => method_name, :access_token => @access_token)
      else
        # method_name is a name of some method
        name = Resolver.vk_method_name(method_name, @namespace)
        type = Resolver.type(method_name)
        
        args = args.first || {}
        args[:access_token] = @access_token unless @access_token.nil?
        
        result = API.call(name, args)
        yield_result(result, type, block)
      end
    end
    
  private
    def yield_result(result, type, block)
      if result.respond_to?(:each)
        # enumerable result receives :map with a block when called with a block
        # or is returned untouched otherwise
        block.nil? ? result : result.map(&block)
      else
        # non-enumerable result is typecasted
        # (and yielded if block_given?)
        result = typecast(result, type)
        block.nil? ? result : block.call(result)
      end
    end
    
    def typecast(parameter, type)
      case type
      when :boolean
        # '1' becomes true, '0' becomes false
        !parameter.to_i.zero?
      else
        parameter
      end
    end
    
    class << self
      # An array of method namespaces.
      # @return [Array]
      attr_reader :namespaces
      
      # Loading namespaces array from `namespaces.yml`.
      # This method is called automatically at startup time.
      def load_namespaces!
        filename    = File.expand_path('../namespaces.yml', __FILE__)
        file        = File.read(filename)
        @namespaces = YAML.load(file)
      end
      
      # A complete method name needed by VKontakte.
      # 
      # Returns a full name and the result type (:boolean or :anything).
      # @example
      #   vk_method_name('is_app_user?')
      #   # => 'isAppUser'
      #   vk_method_name('get_country_by_id', 'places')
      #   # => 'places.getCountryById'
      # @return [Array] full method name and type
      def vk_method_name(method_name, namespace = nil)
        full_name = [namespace, method_name].compact.map { |part| camelize(part) }.join('.')
        # remove everything except letters and dots
        full_name.gsub(/[^A-Za-z.]/, '')
      end
      
      def type(method_name)
        method_name =~ PREDICATE_NAMES ? :boolean : :anything
      end
      
    private
      # camelize('get_profiles')
      # => 'getProfiles'
      def camelize(name)
        words = name.split('_')
        first_word = words.shift
        
        words.each do |word|
          word.sub!(/^[a-z]/, &:upcase)
        end
        
        words.unshift(first_word).join
      end
    end
  end
end

VkontakteApi::Resolver.load_namespaces!
