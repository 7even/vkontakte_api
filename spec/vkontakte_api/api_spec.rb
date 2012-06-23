require 'spec_helper'

describe VkontakteApi::API do
  before(:each) do
    @method_name =  'apiMethod'
    @args = {
      :field        => 'value',
      :access_token => 'some_token'
    }
    
    @logger   = stub("Logger").as_null_object
    VK.logger = @logger
  end
  
  describe ".call" do
    before(:each) do
      @url = stub("URL")
      VkontakteApi::API.stub(:url_for).and_return(@url)
      
      @connection = stub("Faraday connection")
      Faraday.stub(:new).and_return(@connection)
      
      @body = stub("Response body")
      response = stub("Response", :body => @body)
      @connection.stub(:get).and_return(response)
      
      @result_response  = stub("Result[response]")
      @result_error     = stub("Result[error]").as_null_object
      
      @result = {'response' => @result_response}
      
      Yajl::Parser.stub(:parse).and_return(@result)
    end
    
    it "calls the url from .url_for" do
      @connection.should_receive(:get).with(@url)
      VkontakteApi::API.call('apiMethod')
    end
    
    context "with a successful response" do
      context "with VkontakteApi.log_responses?" do
        before(:each) do
          VkontakteApi.log_responses = true
        end
        
        it "calls VkontakteApi.logger.debug with the response body" do
          @logger.should_receive(:debug).with(@body)
          VkontakteApi::API.call('apiMethod')
        end
      end
      
      context "without VkontakteApi.log_responses?" do
        before(:each) do
          VkontakteApi.log_responses = false
        end
        
        it "calls VkontakteApi.logger.debug with the response body" do
          @logger.should_not_receive(:debug)
          VkontakteApi::API.call('apiMethod')
        end
      end
      
      it "returns the response body" do
        VkontakteApi::API.call('apiMethod').should == @result_response
      end
    end
    
    context "with an error response" do
      before(:each) do
        @result['error'] = @result_error
      end
      
      context "with VkontakteApi.log_errors?" do
        before(:each) do
          VkontakteApi.log_errors = true
        end
        
        it "calls VkontakteApi.logger.warn with the response body" do
          @logger.should_receive(:warn).with(@body)
          VkontakteApi::API.call('apiMethod') rescue VkontakteApi::Error
        end
      end
      
      context "without VkontakteApi.log_errors?" do
        before(:each) do
          VkontakteApi.log_errors = false
        end
        
        it "calls VkontakteApi.logger.warn with the response body" do
          @logger.should_not_receive(:warn)
          VkontakteApi::API.call('apiMethod') rescue VkontakteApi::Error
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
    
    context "with an array argument" do
      before(:each) do
        @args_with_array = @args.merge(:array_arg => [1, 2, 3])
      end
      
      it "concats it with a comma" do
        url = VkontakteApi::API.send(:url_for, @method_name, @args_with_array)
        url.should == "/method/apiMethod?access_token=some_token&array_arg=#{CGI.escape('1,2,3')}&field=value"
      end
    end
  end
end
