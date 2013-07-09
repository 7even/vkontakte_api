require 'spec_helper'

describe VkontakteApi::Uploading do
  before(:each) do
    @uploader = Object.new
    @uploader.extend VkontakteApi::Uploading
  end
  
  describe "#upload" do
    before(:each) do
      @upload_io = double("Faraday::UploadIO instance")
      Faraday::UploadIO.stub(:new).and_return(@upload_io)
      
      @response_body = double("Server response body")
      response       = double("Server response", body: @response_body)
      @connection    = double("Faraday connection", post: response)
      VkontakteApi::API.stub(:connection).and_return(@connection)
    end
    
    context "without a :url param" do
      it "raises an ArgumentError" do
        expect {
          @uploader.upload
        }.to raise_error(ArgumentError)
      end
    end
    
    it "creates a Faraday::UploadIO for each file passed in" do
      path = double("File path")
      type = double("File mime type")
      Faraday::UploadIO.should_receive(:new).with(path, type)
      @uploader.upload(url: 'http://example.com', file1: [path, type])
    end
    
    it "POSTs the files through the connection to a given URL" do
      url  = double("URL")
      file = double("File")
      @connection.should_receive(:post).with(url, file1: @upload_io)
      @uploader.upload(url: url, file1: file)
    end
    
    it "returns the server response" do
      @uploader.upload(url: 'http://example.com').should == @response_body
    end
  end
end
