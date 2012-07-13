require 'spec_helper'

describe VkontakteApi::Client do
  before(:each) do
    @user_id      = stub("User id")
    @string_token = stub("Access token as a String")
    @oauth2_token = stub("Access token as an OAuth2::AccessToken", :token => @string_token, :params => {'user_id' => @user_id})
  end
  
  describe "#initialize" do
    context "without arguments" do
      it "creates a client with a nil access_token" do
        client = VkontakteApi::Client.new
        client.token.should be_nil
      end
    end
    
    context "with a token argument" do
      context "with a string value" do
        it "creates a client with a given access_token" do
          client = VkontakteApi::Client.new(@string_token)
          client.token.should == @string_token
        end
      end
      
      context "with an OAuth2::AccessToken value" do
        it "extracts the string token and uses it" do
          client = VkontakteApi::Client.new(@oauth2_token)
          client.token.should == @string_token
          client.user_id.should == @user_id
        end
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
        VkontakteApi::Client.new(@string_token).should be_authorized
      end
    end
  end
end
