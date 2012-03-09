module VkontakteApi
  class Resolver
    PREDICATE_NAMES = /^(is.*)\?$/
    
    attr_reader :namespace
    
    def initialize(options = {})
      @namespace    = options.delete(:namespace)
      @access_token = options.delete(:access_token)
    end
    
    def method_missing(method_name, *args, &block)
      method_name = method_name.to_s
      
      if Resolver.namespaces.include?(method_name)
        # method with a two-level name called
        Resolver.new(:namespace => method_name, :access_token => @access_token)
      else
        # method with a one-level name called
        name, type = Resolver.vk_method_name(method_name, @namespace)
        
        # adding access_token to the args hash
        args = args.first || {}
        args.update(:access_token => @access_token)
        
        result = API.call(name, args, &block)
        
        if result.respond_to?(:each)
          # enumerable result receives :map with a block when called with a block
          # or is returned untouched otherwise
          block_given? ? result.map(&block) : result
        else
          # non-enumerable result is typecasted
          # (and yielded if block_given?)
          result = typecast(result, type)
          block_given? ? yield(result) : result
        end
      end
    end
    
  private
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
      attr_reader :namespaces
      
      # load namespaces array from namespaces.yml
      def load_namespaces
        filename    = File.expand_path('../namespaces.yml', __FILE__)
        file        = File.read(filename)
        @namespaces = YAML.load(file)
      end
      
      # vk_method_name('get_country_by_id', 'places')
      # => 'places.getCountryById'
      def vk_method_name(method_name, namespace = nil)
        method_name = method_name.to_s
        
        if method_name =~ PREDICATE_NAMES
          # predicate methods should return true or false
          method_name.sub!(PREDICATE_NAMES, '\1')
          type = :boolean
        else
          # other methods can return anything they want
          type = :anything
        end
        
        full_name = ''
        full_name << convert(namespace) + '.' unless namespace.nil?
        full_name << convert(method_name)
        
        [full_name, type]
      end
      
    private
      # convert('get_profiles')
      # => 'getProfiles'
      def convert(name)
        name.camelize(:lower)
      end
    end
  end
end

VkontakteApi::Resolver.load_namespaces
