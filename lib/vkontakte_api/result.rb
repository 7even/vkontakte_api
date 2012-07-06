module VkontakteApi
  module Result
    class << self
      # @raise [VkontakteApi::Error] raised when VKontakte returns an error.
      def process(response, type, block)
        result = extract_result(response)
        
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
      
    private
      def extract_result(response)
        if response.error?
          raise VkontakteApi::Error.new(response.error)
        else
          response.response
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
    end
  end
end
