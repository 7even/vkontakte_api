require 'spec_helper'

describe VkontakteApi::Authentication do
  before(:each) do
    @app_id = stub("App id")
    VkontakteApi.stub(:app_id).and_return(@app_id)
    @app_secret = stub("App secret")
    VkontakteApi.stub(:app_secret).and_return(@app_secret)
    @redirect_uri = stub("Redirect uri")
    VkontakteApi.stub(:redirect_uri).and_return(@redirect_uri)
    
    @url   = stub("Authorization url")
    @token = stub("Token")
    
    @auth_code          = stub("Authentication code strategy", :get_token => @token, :authorize_url => @url)
    @implicit           = stub("Implicit strategy",            :authorize_url => @url)
    @client_credentials = stub("Client credentials strategy",  :get_token => @token)
    
    @client = stub("OAuth2::Client instance", :auth_code => @auth_code, :implicit => @implicit, :client_credentials => @client_credentials)
    OAuth2::Client.stub(:new).and_return(@client)
    
    @auth = Object.new
    @auth.extend VkontakteApi::Authentication
  end
  
  describe "#authentication_url" do
    before(:each) do
      @auth.stub(:client).and_return(@client)
    end
    
    context "with auth_code strategy" do
      it "returns a valid authorization url" do
        @auth_code.should_receive(:authorize_url).with(:redirect_uri => @redirect_uri)
        @auth.authentication_url(:strategy => :auth_code).should == @url
      end
    end
    
    context "with an implicit strategy" do
      it "returns a valid authorization url" do
        @implicit.should_receive(:authorize_url).with(:redirect_uri => @redirect_uri)
        @auth.authentication_url(:strategy => :implicit).should == @url
      end
    end
    
    context "given a redirect_uri" do
      it "prefers the given uri over VkontakteApi.redirect_uri" do
        redirect_uri = 'http://example.com/oauth/callback'
        @auth_code.should_receive(:authorize_url).with(:redirect_uri => redirect_uri)
        @auth.authentication_url(:redirect_uri => redirect_uri)
      end
    end
    
    context "given a scope" do
      it "sends it to VkontakteApi::Utils.flatten_argument" do
        scope = stub("Scope")
        flat_scope = stub("Flat scope")
        
        VkontakteApi::Utils.should_receive(:flatten_argument).with(scope).and_return(flat_scope)
        @auth_code.should_receive(:authorize_url).with(:redirect_uri => @redirect_uri, :scope => flat_scope)
        @auth.authentication_url(:scope => scope)
      end
    end
  end
  
  describe "#authenticate" do
    context "with auth_code strategy" do
      before(:each) do
        @code = stub("Authentication code")
        @auth_code.stub(:get_token).and_return(@token)
      end
      
      it "gets the token" do
        @auth_code.should_receive(:get_token).with(@code)
        @auth.authenticate(:strategy => :auth_code, :code => @code)
      end
    end
    
    context "with client_credentials strategy" do
      it "gets the token" do
        @client_credentials.should_receive(:get_token).with({}, subject::OPTIONS[:client_credentials])
        @auth.authenticate(:strategy => :client_credentials)
      end
    end
    
    context "with unknown strategy" do
      it "raises an ArgumentError" do
        expect {
          @auth.authenticate(:strategy => :starcraft)
        }.to raise_error(ArgumentError)
      end
    end
    
    it "builds a VkontakteApi::Client instance with the received token" do
      client = stub("VkontakteApi::Client instance")
      VkontakteApi::Client.should_receive(:new).with(@token).and_return(client)
      @auth.authenticate.should == client
    end
  end
  
  describe "#client" do
    it "creates and returns an OAuth2::Client instance" do
      OAuth2::Client.should_receive(:new).with(@app_id, @app_secret, subject::OPTIONS[:client])
      @auth.send(:client).should == @client
    end
    
    it "caches the result" do
      OAuth2::Client.should_receive(:new).once
      5.times { @auth.send(:client) }
    end
  end
end
