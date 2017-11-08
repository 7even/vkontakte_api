module VkontakteApi
  # An exception raised by `VkontakteApi::Result` when given a response with errors from `execute` API method.
  class ExecuteError < StandardError
    # An exception is initialized by the data from response.
    # @param [Array] errors Errors data.
    def initialize(errors)
      @errors = errors
    end

    # A full description of the error.
    # @return [String]
    def message
      message = 'VKontakte returned the following errors:'

      @errors.each do |error|
        message << "\n * Code #{error[:error_code]}: '#{error[:error_msg]}'"
        message << "\n   after calling method '#{error[:method]}'."
      end

      message
    end
  end
end
