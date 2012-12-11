require 'spec_helper'

describe VkontakteApi::Client do
  before(:each) do
    @user_id      = stub("User id")
    @string_token = stub("Access token as a String")
    @expires_at   = stub("Token expiration timestamp")
    
    @oauth2_token = stub("Access token as an OAuth2::AccessToken")
    @oauth2_token.stub(:token).and_return(@string_token)
    @oauth2_token.stub(:params).and_return('user_id' => @user_id)
    @oauth2_token.stub(:expires_at).and_return(@expires_at)
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
          expiration_time = stub("Some time")
          Time.should_receive(:at).with(@expires_at).and_return(expiration_time)
          
          client = VkontakteApi::Client.new(@oauth2_token)
          client.token.should == @string_token
          client.user_id.should == @user_id
          client.expires_at.should == expiration_time
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
  
  describe "#scope" do
    before(:each) do
      @client = VkontakteApi::Client.new
      @client.stub(:get_user_settings).and_return(865310)
    end
    
    it "returns an array of access rights" do
      scopes_array = @client.scope
      
      [
        :friends,
        :photos,
        :audio,
        :video,
        :status,
        :messages,
        :wall,
        :groups,
        :notifications
      ].each do |access_scope|
        scopes_array.should include(access_scope)
      end
    end
  end
end
