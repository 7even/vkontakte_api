module VkontakteApi
  # An exception raised by `VkontakteApi::Result` when given a response with an error.
  class ExecuteError < StandardError

    # An exception is initialized by the data from response mash.
    # @param [Array] errors Error data.
    def initialize(errors)
      @errors = errors
    end

    # A full description of the error.
    # @return [String]
    def message
      message = 'VKontakte returned an errors:'

      @errors.each_with_index do |error, index|
        message << "\n #{index+1}) Code #{error[:error_code]}: '#{error[:error_msg]}'"
        message << "\n    after calling method '#{error[:method]}'."
      end

      message
    end
  end
end
