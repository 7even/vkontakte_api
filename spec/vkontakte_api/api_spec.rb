require 'spec_helper'

describe VkontakteApi::API do
  before(:each) do
    @method_name =  'apiMethod'
    @args = {
      :field        => 'value',
      :access_token => 'some_token'
    }
  end
  
  describe ".call" do
    before(:each) do
      @url = stub("URL")
      VkontakteApi::API.stub(:url_for).and_return(@url)
      
      @connection = stub("Faraday connection")
      Faraday.stub(:new).and_return(@connection)
      
      body = stub("Response body")
      response = stub("Response", :body => body)
      @connection.stub(:get).and_return(response)
      
      @result = stub("Result")
      @result.stub(:has_key?) do |key|
        if key == 'response'
          true
        else
          false
        end
      end
      
      @result_response  = stub("Result[response]")
      @result_error     = stub("Result[error]").as_null_object
      
      @result.stub(:[]) do |key|
        if key == :response
          @result_response
        else
          @result_error
        end
      end
      
      Yajl::Parser.stub(:parse).and_return(@result)
    end
    
    it "calls the url from .url_for" do
      @connection.should_receive(:get).with(@url)
      VkontakteApi::API.call('apiMethod')
    end
    
    context "with a successful response" do
      it "returns the response body" do
        VkontakteApi::API.call('apiMethod').should == @result_response
      end
    end
    
    context "with an error response" do
      before(:each) do
        @result.stub(:has_key?) do |key|
          if key == 'response'
            false
          else
            true
          end
        end
      end
      
      it "raises a VkontakteApi::Error" do
        expect {
          VkontakteApi::API.call('apiMethod')
        }.to raise_error(VkontakteApi::Error)
      end
    end
  end
  
  describe ".url_for" do
    it "constructs a valid VK API url" do
      url = VkontakteApi::API.send(:url_for, @method_name, @args)
      url.should == '/method/apiMethod?access_token=some_token&field=value'
    end
  end
end
