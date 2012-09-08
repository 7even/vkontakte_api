require 'spec_helper'

describe VkontakteApi::API do
  def create_connection
    @result = {'response' => {'key' => 'value'}}
    
    @connection = Faraday.new do |builder|
      builder.response :mashify
      builder.response :oj, :preserve_raw => true
      builder.adapter  :test do |stub|
        stub.get('/apiMethod') do
          [200, {}, Oj.dump(@result)]
        end
      end
    end
    subject.stub(:connection).and_return(@connection)
  end
  
  describe ".call" do
    before(:each) do
      create_connection
    end
    
    context "called with a token parameter" do
      it "sends it to .connection" do
        subject.should_receive(:connection).with(:url => VkontakteApi::API::URL_PREFIX, :token => 'token')
        subject.call('apiMethod', {:some => :params}, 'token')
      end
    end
    
    it "returns the response body" do
      subject.call('apiMethod').should == @result
    end
    
    it "uses an HTTP verb from VkontakteApi.http_verb" do
      http_verb = stub("HTTP verb")
      VkontakteApi.http_verb = http_verb
      
      response = stub("Response", :body => stub)
      @connection.should_receive(:send).with(http_verb, 'apiMethod', {}).and_return(response)
      subject.call('apiMethod')
    end
    
    after(:each) do
      VkontakteApi.reset
    end
  end
  
  describe ".connection" do
    it "uses the :url parameter and VkontakteApi.faraday_options" do
      faraday_options = stub("Faraday options")
      VkontakteApi.stub(:faraday_options).and_return(faraday_options)
      url = stub("URL")
      Faraday.should_receive(:new).with(url, faraday_options)
      connection = subject.connection(:url => url)
    end
    
    context "without a token" do
      it "creates a connection without an oauth2 middleware" do
        connection = subject.connection
        connection.builder.handlers.map(&:name).should_not include('FaradayMiddleware::OAuth2')
      end
    end
    
    context "with a token" do
      before(:each) do
        @token = stub("Token")
      end
      
      it "creates a connection with an oauth2 middleware" do
        connection = subject.connection(:token => @token)
        handler = connection.builder.handlers.first
        handler.name.should == 'FaradayMiddleware::OAuth2'
        handler.instance_variable_get(:@args).should == [@token]
      end
    end
  end
end
