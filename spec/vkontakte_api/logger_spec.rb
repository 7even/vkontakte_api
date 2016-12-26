require 'spec_helper'

describe VkontakteApi::Logger do
  before(:each) do
    VkontakteApi.logger = double("Logger").as_null_object
    
    VkontakteApi.log_requests  = false
    VkontakteApi.log_responses = false
    VkontakteApi.log_errors    = false
  end
  
  let(:success_response) { MultiJson.dump('a' => 1, 'b' => 2) }
  let(:fail_response) { MultiJson.dump('error' => 404) }
  
  let(:connection) do
    Faraday.new(url: 'http://example.com') do |builder|
      builder.request  :url_encoded
      builder.response :vk_logger
      builder.response :mashify
      builder.response :multi_json, preserve_raw: true
      
      builder.adapter :test do |stub|
        stub.get('/success') do
          [200, {}, success_response]
        end
        
        stub.post('/success') do
          [200, {}, success_response]
        end
        
        stub.get('/fail') do
          [200, {}, fail_response]
        end
      end
    end
  end
  
  context "with VkontakteApi.log_requests?" do
    before(:each) do
      VkontakteApi.log_requests = true
    end
    
    it "logs the request URL" do
      expect(VkontakteApi.logger).to receive(:debug).with('GET http://example.com/success')
      connection.get('/success')
    end
    
    context "with a POST request" do
      it "logs the request URL and the request body" do
        expect(VkontakteApi.logger).to receive(:debug).with('POST http://example.com/success')
        expect(VkontakteApi.logger).to receive(:debug).with('body: "param=1"')
        connection.post('/success', param: 1)
      end
    end
  end
  
  context "without VkontakteApi.log_requests?" do
    it "doesn't log the request" do
      expect(VkontakteApi.logger).not_to receive(:debug)
      connection.get('/success')
    end
  end
  
  context "with a successful response" do
    context "with VkontakteApi.log_responses?" do
      before(:each) do
        VkontakteApi.log_responses = true
      end
      
      it "logs the response body" do
        expect(VkontakteApi.logger).to receive(:debug).with(success_response)
        connection.get('/success')
      end
    end
    
    context "without VkontakteApi.log_responses?" do
      it "doesn't log the response body" do
        expect(VkontakteApi.logger).not_to receive(:debug)
        connection.get('/success')
      end
    end
  end
  
  context "with an error response" do
    context "with VkontakteApi.log_errors?" do
      before(:each) do
        VkontakteApi.log_errors = true
      end
      
      it "logs the response body" do
        expect(VkontakteApi.logger).to receive(:warn).with(fail_response)
        connection.get('/fail')
      end
    end
    
    context "without VkontakteApi.log_errors?" do
      it "doesn't log the response body" do
        expect(VkontakteApi.logger).not_to receive(:warn)
        connection.get('/fail')
      end
    end
  end
end
