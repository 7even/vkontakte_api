module VkontakteApi
  class Method
    include Resolvable
    
    # A pattern for names of methods with a boolean result.
    PREDICATE_NAMES = /^is.*\?$/
    
    def call(args = {}, &block)
      response = API.call(full_name, args, token)
      Result.process(response, type, block)
    end
    
  private
    def full_name
      parts = [@previous_resolver.name, @name].compact.map { |part| camelize(part) }
      parts.join('.').gsub(/[^A-Za-z.]/, '')
    end
    
    def type
      @name =~ PREDICATE_NAMES ? :boolean : :anything
    end
    
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
