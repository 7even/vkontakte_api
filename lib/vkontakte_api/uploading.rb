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
    #     file2: [io_object, 'image/png', '/path/to/file2.png']
    #   )
    #   VkontakteApi.upload(
    #     url:   'http://example.com/upload',
    #     files: [['/path/to/file1.jpg', 'image/jpeg'], [io_object, 'image/png', '/path/to/file2.png']],
    #   )

    def upload(params = {})
      url = params.delete(:url)
      raise ArgumentError, 'You should pass :url parameter' unless url
      
      upfiles = params.delete(:files).compact
      upfiles.each_index do |i|
        params["file#{i+1}".to_sym] = upfiles[i]
      end
      files = {}
      params.each do |param_name, (file_path_or_io, file_type, file_path)|
        files[param_name] = Faraday::UploadIO.new(file_path_or_io, file_type, file_path)
      end
      
      API.connection.post(url, files).body
    end
  end
end
