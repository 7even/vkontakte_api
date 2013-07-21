require 'spec_helper'

describe VkontakteApi::API do
  def create_connection
    @result = { 'response' => { 'key' => 'value' } }
    
    @connection = Faraday.new do |builder|
      builder.response :mashify
      builder.response :oj, preserve_raw: true
      builder.adapter  :test do |stub|
        stub.post('/apiMethod') do
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
        expect(subject).to receive(:connection).with(url: VkontakteApi::API::URL_PREFIX, token: 'token')
        subject.call('apiMethod', { some: :params }, 'token')
      end
    end
    
    it "returns the response body" do
      expect(subject.call('apiMethod')).to eq(@result)
    end
    
    it "uses an HTTP verb from VkontakteApi.http_verb" do
      http_verb = double("HTTP verb")
      VkontakteApi.http_verb = http_verb
      
      response = double("Response", body: double)
      expect(@connection).to receive(:send).with(http_verb, 'apiMethod', {}).and_return(response)
      subject.call('apiMethod')
    end
    
    after(:each) do
      VkontakteApi.reset
    end
  end
  
  describe ".connection" do
    it "uses the :url parameter and VkontakteApi.faraday_options" do
      faraday_options = double("Faraday options")
      VkontakteApi.stub(:faraday_options).and_return(faraday_options)
      url = double("URL")
      
      expect(Faraday).to receive(:new).with(url, faraday_options)
      subject.connection(url: url)
    end
    
    context "without a token" do
      it "creates a connection without an oauth2 middleware" do
        handler_names = subject.connection.builder.handlers.map(&:name)
        expect(handler_names).not_to include('FaradayMiddleware::OAuth2')
      end
    end
    
    context "with a token" do
      let(:token) { double("Token") }
      
      it "creates a connection with an oauth2 middleware" do
        connection = subject.connection(token: token)
        handler = connection.builder.handlers.first
        
        expect(handler.name).to eq('FaradayMiddleware::OAuth2')
        expect(handler.instance_variable_get(:@args)).to eq([token])
      end
    end
  end
end
