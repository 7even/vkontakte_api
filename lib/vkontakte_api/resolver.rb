module VkontakteApi
  class Resolver
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
        name = Resolver.vk_method_name(method_name, @namespace)
        
        # adding access_token to the args hash
        args = args.first || {}
        args.update(:access_token => @access_token)
        
        API.call(name, args, &block)
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
        full_name = ''
        full_name << "#{convert(namespace)}." unless namespace.nil?
        full_name << convert(method_name)
      end
    private
      # convert('get_profiles')
      # => 'getProfiles'
      def convert(name)
        name.to_s.camelize(:lower)
      end
    end
  end
end

VkontakteApi::Resolver.load_namespaces
