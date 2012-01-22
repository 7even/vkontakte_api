require 'spec_helper'

describe VkontakteApi::Client do
  before(:each) do
    @token = stub("Access token")
  end
  
  describe "#initialize" do
    context "without arguments" do
      it "creates a client with a nil access_token" do
        VkontakteApi::Client.new.access_token.should be_nil
      end
    end
    
    context "with a token argument" do
      it "creates a client with a given access_token" do
        client = VkontakteApi::Client.new(@token)
        client.access_token.should == @token
      end
    end
  end
  
  describe "#authorized?" do
    context "with an unauthorized client" do
      it "returns false" do
        VkontakteApi::Client.new.should_not be_authorized
      end
    end
    
    context "with an authorized client" do
      it "returns true" do
        VkontakteApi::Client.new(@token).should be_authorized
      end
    end
  end
  
  describe "API methods" do
    before(:each) do
      @client = VkontakteApi::Client.new
      VkontakteApi::Client.stub(:vk_method_name).and_return('apiMethod')
      @client.stub(:api_call)
    end
    
    it "call #vk_method_name" do
      VkontakteApi::Client.should_receive(:vk_method_name)
      @client.api_method
    end
    
    it "call #api_call with VK method name" do
      @client.should_receive(:api_call).with('apiMethod')
      @client.api_method
    end
  end
  
  describe ".vk_method_name" do
    it "converts it's argument to camelCase string" do
      VkontakteApi::Client.vk_method_name(:api_method).should == 'apiMethod'
    end
  end
end
