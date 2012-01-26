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
  
  describe "#method_missing" do
    before(:each) do
      @resolver = stub("Resolver").as_null_object
      VkontakteApi::Resolver.stub(:new).and_return(@resolver)
      @args = {:field => 'value'}
    end
    
    it "creates a resolver, passing it the access_token" do
      VkontakteApi::Resolver.should_receive(:new).with(:access_token => @token)
      VkontakteApi::Client.new(@token).api_method(@args)
    end
    
    it "delegates to VkontakteApi::Resolver" do
      @resolver.should_receive(:api_method).with(@args)
      VkontakteApi::Client.new(@token).api_method(@args)
    end
  end
end
