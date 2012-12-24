module VkontakteApi
  # An exception raised by `VkontakteApi::Result` when given a response with an error.
  class Error < StandardError
    # An error code.
    # @return [Fixnum]
    attr_reader :error_code
    # Captcha identifier (only for "Captcha needed" errors).
    # @return [String]
    attr_reader :captcha_sid
    # Captcha image URL (only for "Captcha needed" errors).
    # @return [String]
    attr_reader :captcha_img
    
    # An exception is initialized by the data from response mash.
    # @param [Hash] data Error data.
    def initialize(data)
      @error_code = data.error_code
      @error_msg  = data.error_msg
      
      request_params = parse_params(data.request_params)
      
      @method_name  = request_params.delete('method')
      @access_token = request_params.delete('access_token')
      @oauth        = request_params.delete('oauth')
      @params       = request_params
      
      @captcha_sid  = data.captcha_sid
      @captcha_img  = data.captcha_img
    end
    
    # A full description of the error.
    # @return [String]
    def message
      message = "VKontakte returned an error #{@error_code}: '#{@error_msg}'"
      message << " after calling method '#{@method_name}'"
      
      if @params.empty?
        message << " without parameters."
      else
        message << " with parameters #{@params.inspect}."
      end
      
      message
    end
    
  private
    def parse_params(params)
      params.inject({}) do |memo, pair|
        memo[pair[:key]] = pair[:value]
        memo
      end
    end
  end
end
