require 'spec_helper'

describe VkontakteApi::Client do
  before(:each) do
    @user_id = double("User id")
  end
  
  def oauth2_token(expires_at = Time.now)
    token = double("Access token as an OAuth2::AccessToken").tap do |token|
      token.stub(:token).and_return(string_token)
      token.stub(:params).and_return('user_id' => @user_id)
      token.stub(:expires_at).and_return(expires_at)
    end
  end
  
  let(:string_token)  { double("Access token as a String") }
  let(:expired_token) { oauth2_token(Time.now - 2 * 60 * 60) }
  let(:actual_token)  { oauth2_token(Time.now + 2 * 60 * 60) }
  
  describe "#initialize" do
    context "without arguments" do
      let(:client) { VkontakteApi::Client.new }
      
      it "creates a client with a nil access_token" do
        expect(client.token).to be_nil
      end
    end
    
    context "with a token argument" do
      context "with a string value" do
        let(:client) { VkontakteApi::Client.new(string_token) }
        
        it "creates a client with a given access_token" do
          expect(client.token).to eq(string_token)
        end
      end
      
      context "with an OAuth2::AccessToken value" do
        let(:client) { VkontakteApi::Client.new(oauth2_token) }
        
        it "extracts the string token and uses it" do
          expect(client.token).to eq(string_token)
          expect(client.user_id).to eq(@user_id)
          
          expect(client.expires_at).to be_a(Time)
          expect(client.expires_at).to be < Time.now
        end
      end
    end
  end
  
  describe "#authorized?" do
    context "with an unauthorized client" do
      let(:client) { VkontakteApi::Client.new }
      
      it "returns false" do
        expect(client).not_to be_authorized
      end
    end
    
    context "with an authorized client" do
      let(:client) { VkontakteApi::Client.new(string_token) }
      
      it "returns true" do
        expect(client).to be_authorized
      end
    end
  end
  
  describe "#expired?" do
    context "with an expired token" do
      let(:client) { VkontakteApi::Client.new(expired_token) }
      
      it "returns true" do
        expect(client).to be_expired
      end
    end
    
    context "with an actual token" do
      let(:client) { VkontakteApi::Client.new(actual_token) }
      
      it "returns false" do
        expect(client).not_to be_expired
      end
    end
    
    context "with a String token" do
      let(:client) { VkontakteApi::Client.new(string_token) }
      
      it "returns false" do
        expect(client).not_to be_expired
      end
    end
  end
  
  describe "#scope" do
    let(:client) do
      VkontakteApi::Client.new.tap do |client|
        client.stub(:get_user_settings).and_return(865310)
      end
    end
    let(:scope) { client.scope }
    
    it "returns an array of access rights" do
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
        expect(scope).to include(access_scope)
      end
    end
  end
  
  describe "#method_missing" do
    let(:client) do
      token = double("Token")
      VkontakteApi::Client.new(token)
    end
    
    context "called with a namespace" do
      it "returns a Namespace instance" do
        expect(client.users).to be_a(VkontakteApi::Namespace)
      end
    end
    
    context "called with a method" do
      before(:each) do
        @result = double("Result")
        @method = double("Method", call: @result)
        VkontakteApi::Method.stub(:new).and_return(@method)
      end
      
      it "creates a Method instance" do
        expect(VkontakteApi::Method).to receive(:new).with(:get, resolver: client.resolver)
        client.get(id: 1)
      end
      
      it "calls Method#call and returns the result" do
        expect(@method).to receive(:call).with(id: 1)
        expect(client.get(id: 1)).to eq(@result)
      end
    end
  end
end
