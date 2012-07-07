require 'spec_helper'

describe VkontakteApi::Logger do
  before(:each) do
    @success_response = Oj.dump('a' => 1, 'b' => 2)
    @fail_response    = Oj.dump('error' => 404)
    
    @connection = Faraday.new(:url => 'http://example.com') do |builder|
      builder.response :vk_logger
      builder.response :mashify
      builder.response :oj, :preserve_raw => true
      
      builder.adapter :test do |stub|
        stub.get('/success') do
          [200, {}, @success_response]
        end
        stub.get('/fail') do
          [200, {}, @fail_response]
        end
      end
    end
    
    @logger = stub("Logger").as_null_object
    VkontakteApi.logger = @logger
    
    VkontakteApi.log_requests  = false
    VkontakteApi.log_responses = false
    VkontakteApi.log_errors    = false
  end
  
  context "with VkontakteApi.log_requests?" do
    before(:each) do
      VkontakteApi.log_requests = true
    end
    
    it "logs the request" do
      @logger.should_receive(:debug).with('GET http://example.com/success')
      @connection.get('/success')
    end
  end
  
  context "without VkontakteApi.log_requests?" do
    it "doesn't log the request" do
      @logger.should_not_receive(:debug)
      @connection.get('/success')
    end
  end
  
  context "with a successful response" do
    context "with VkontakteApi.log_responses?" do
      before(:each) do
        VkontakteApi.log_responses = true
      end
      
      it "logs the response body" do
        @logger.should_receive(:debug).with(@success_response)
        @connection.get('/success')
      end
    end
    
    context "without VkontakteApi.log_responses?" do
      it "doesn't log the response body" do
        @logger.should_not_receive(:debug)
        @connection.get('/success')
      end
    end
  end
  
  context "with an error response" do
    context "with VkontakteApi.log_errors?" do
      before(:each) do
        VkontakteApi.log_errors = true
      end
      
      it "logs the response body" do
        @logger.should_receive(:warn).with(@fail_response)
        @connection.get('/fail')
      end
    end
    
    context "without VkontakteApi.log_errors?" do
      it "doesn't log the response body" do
        @logger.should_not_receive(:warn)
        @connection.get('/fail')
      end
    end
  end
end
