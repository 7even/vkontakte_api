module VkontakteApi
  # An API method. It is responsible for generating it's full name and determining it's type.
  class Method
    include Resolvable
    
    # A pattern for names of methods with a boolean result.
    PREDICATE_NAMES = /^is.*\?$/
    
    # Calling the API method.
    # It delegates the network request to `API.call` and result processing to `Result.process`.
    # @param [Hash] args Arguments for the API method.
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
