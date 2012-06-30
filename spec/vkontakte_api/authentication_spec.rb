require 'spec_helper'

describe VkontakteApi::Authentication do
  before(:each) do
    @app_id = stub("App id")
    VkontakteApi.stub(:app_id).and_return(@app_id)
    @app_secret = stub("App secret")
    VkontakteApi.stub(:app_secret).and_return(@app_secret)
    @redirect_uri = stub("Redirect uri")
    VkontakteApi.stub(:redirect_uri).and_return(@redirect_uri)
    
    @auth_code = stub("Authentication code strategy")
    @client = stub("OAuth2::Client instance", :auth_code => @auth_code)
    OAuth2::Client.stub(:new).and_return(@client)
    
    @auth = Object.new
    @auth.extend VkontakteApi::Authentication
  end
  
  describe "#authentication_url" do
    before(:each) do
      @options = {:strategy => :auth_code}
      @url = stub("Authorization url")
      @auth_code.stub(:authorize_url).and_return(@url)
      @auth.stub(:client).and_return(@client)
    end
    
    it "calls #client" do
      @auth.should_receive(:client)
      @auth.authentication_url
    end
    
    it "returns a valid authorization url" do
      @auth_code.should_receive(:authorize_url).with(:redirect_uri => @redirect_uri)
      @auth.authentication_url(@options).should == @url
    end
    
    context "given a redirect_uri" do
      before(:each) do
        @options[:redirect_uri] = 'http://example.com/oauth/callback'
      end
      
      it "prefers the given uri over VkontakteApi.redirect_uri" do
        @auth_code.should_receive(:authorize_url).with(:redirect_uri => @options[:redirect_uri])
        @auth.authentication_url(@options)
      end
    end
    
    context "given a scope" do
      it "sends it to VkontakteApi::Utils.flatten_argument" do
        scope = stub("Scope")
        @options[:scope] = scope
        flat_scope = stub("Flat scope")
        
        VkontakteApi::Utils.should_receive(:flatten_argument).with(scope).and_return(flat_scope)
        @auth_code.should_receive(:authorize_url).with(:redirect_uri => @redirect_uri, :scope => flat_scope)
        @auth.authentication_url(@options)
      end
    end
  end
  
  describe "#authenticate" do
    before(:each) do
      @code = stub("Authentication code")
      @options = {:strategy => :auth_code, :code => @code}
      @token = stub("Token")
      @auth_code.stub(:get_token).and_return(@token)
    end
    
    it "gets the token" do
      @auth_code.should_receive(:get_token).with(@code)
      @auth.authenticate(@options)
    end
    
    it "builds a VkontakteApi::Client instance with the received token" do
      client = stub("VkontakteApi::Client instance")
      VkontakteApi::Client.should_receive(:new).with(@token).and_return(client)
      @auth.authenticate(@options).should == client
    end
  end
  
  describe "#client" do
    it "creates and returns an OAuth2::Client instance" do
      OAuth2::Client.should_receive(:new).with(@app_id, @app_secret, :site => VkontakteApi::Authentication::URLS[:authorize_url])
      @auth.send(:client).should == @client
    end
    
    it "caches the result" do
      OAuth2::Client.should_receive(:new).once
      5.times { @auth.send(:client) }
    end
  end
end
