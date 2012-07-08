module VkontakteApi
  # A module implementing files uploading functionality.
  # 
  # @note `VkontakteApi::Uploading` extends `VkontakteApi` so these methods should be called from the latter.
  module Uploading
    # Files uploading. It uses the same faraday middleware stack as API method calls (by using `VkontakteApi::API.connection`).
    # @param [Hash] params A list of files to upload (also includes the upload URL). See example for the hash format.
    # @option params [String] :url URL for the request.
    # @return [Hashie::Mash] The server response.
    # @raise [ArgumentError] raised when a `:url` parameter is omitted.
    # @example
    #   VkontakteApi.upload(
    #     url:   'http://example.com/upload',
    #     file1: ['/path/to/file1.jpg', 'image/jpeg'],
    #     file2: ['/path/to/file2.png', 'image/png']
    #   )
    def upload(params = {})
      url = params.delete(:url)
      raise ArgumentError, 'You should pass :url parameter' unless url
      
      files = {}
      params.each do |param_name, (file_path, file_type)|
        files[param_name] = Faraday::UploadIO.new(file_path, file_type)
      end
      
      API.connection.post(url, files).body
    end
  end
end
