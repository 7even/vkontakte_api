require 'spec_helper'

describe VkontakteApi::Client do
  before(:each) do
    @token = stub("Access token")
  end
  
  describe "#initialize" do
    context "without arguments" do
      it "creates a client with a nil access_token" do
        client = VkontakteApi::Client.new
        client.token.should be_nil
      end
    end
    
    context "with a token argument" do
      it "creates a client with a given access_token" do
        client = VkontakteApi::Client.new(@token)
        client.token.should == @token
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
end
