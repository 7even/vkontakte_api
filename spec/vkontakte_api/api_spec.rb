require 'spec_helper'

describe VkontakteApi::API do
  def create_connection
    @result = {'response' => {'key' => 'value'}}
    
    @connection = Faraday.new do |builder|
      builder.response :mashify
      builder.response :json, :preserve_raw => true
      builder.adapter  :test do |stub|
        stub.get('/url') do
          [200, {}, Oj.dump(@result)]
        end
      end
    end
    subject.stub(:connection).and_return(@connection)
  end
  
  describe ".call" do
    before(:each) do
      create_connection
      subject.stub(:url_for).and_return('/url')
    end
    
    context "called with a token parameter" do
      it "sends it to .connection" do
        subject.should_receive(:connection).with('token')
        subject.call('apiMethod', {:some => :params}, 'token')
      end
    end
    
    it "returns the response body" do
      subject.call('apiMethod').should == @result
    end
  end
  
  describe ".connection" do
    context "without a token" do
      it "creates a connection without an oauth2 middleware" do
        connection = subject.send(:connection)
        connection.builder.handlers.map(&:name).should_not include('FaradayMiddleware::OAuth2')
      end
    end
    
    context "with a token" do
      it "creates a connection with an oauth2 middleware" do
        connection = subject.send(:connection, :token)
        handler = connection.builder.handlers.first
        handler.name.should == 'FaradayMiddleware::OAuth2'
        handler.instance_variable_get(:@args).should == [:token]
      end
    end
  end
  
  describe ".url_for" do
    before(:each) do
      create_connection
    end
    
    it "converts the arguments and sends them to connection.build_url" do
      args = stub("Arguments")
      flat_args = stub("Flat arguments")
      
      VkontakteApi::Utils.should_receive(:flatten_arguments).with(args).and_return(flat_args)
      @connection.should_receive(:build_url).with(:method_name, flat_args)
      VkontakteApi::API.send(:url_for, :method_name, args)
    end
  end
end
