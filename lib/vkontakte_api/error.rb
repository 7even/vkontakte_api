module VkontakteApi
  class Error < StandardError
    def initialize(data)
      @error_code = data.delete(:error_code)
      @error_msg  = data.delete(:error_msg)
      @params     = {}
      
      request_params = parse_params(data.delete :request_params)
      
      @method_name  = request_params.delete('method')
      @access_token = request_params.delete('access_token')
      @oauth        = request_params.delete('oauth')
      @params       = request_params
    end
    
    def message
      "VKontakte returned an error #{@error_code}: \'#{@error_msg}\' after calling method \'#{@method_name}\' with parameters #{@params.inspect}."
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
