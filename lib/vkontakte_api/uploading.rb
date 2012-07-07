module VkontakteApi
  module Uploading
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
