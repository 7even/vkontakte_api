module VkontakteApi
  class Resolver
    # this array needs to be stored in YAML
    NAMESPACES = %w(friends groups photos wall newsfeed notifications audio video docs places secure storage notes pages activity offers questions subscriptions messages likes status polls)
    
    attr_reader :namespace
    
    def initialize(namespace = nil)
      @namespace = namespace
    end
    
    def method_missing(method_name, *args, &block)
      method_name = method_name.to_s
      
      if NAMESPACES.include?(method_name)
        # method with a two-level name called
        Resolver.new(method_name)
      else
        # method with a one-level name called
        name = Resolver.vk_method_name(method_name, @namespace)
        API.call(name, *args, &block)
      end
    end
    
    class << self
      def vk_method_name(method_name, namespace = nil)
        full_name = ''
        full_name << "#{convert(namespace)}." unless namespace.nil?
        full_name << convert(method_name)
      end
    private
      def convert(name)
        name.to_s.camelize(:lower)
      end
    end
  end
end
