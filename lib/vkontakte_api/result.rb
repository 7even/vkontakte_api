module VkontakteApi
  # A module that handles method result processing.
  #
  # It implements method blocks support, result typecasting and raises `VkontakteApi::Error` in case of an error response.
  module Result
    class << self
      # The main method result processing.
      # @param [Hashie::Mash] response The server response in mash format.
      # @param [Symbol] type The expected result type (`:boolean` or `:anything`).
      # @param [Proc] block A block passed to the API method.
      # @return [Array, Hashie::Mash] The processed result.
      # @raise [VkontakteApi::Error] raised when VKontakte returns an error response.
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
        return unless response.is_a? Hash

        if response.error?
          raise VkontakteApi::Error.new(response.error)
        elsif response.execute_errors?
          raise VkontakteApi::ExecuteError.new(response.execute_errors)
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
