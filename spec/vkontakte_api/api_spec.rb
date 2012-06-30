require 'spec_helper'

describe VkontakteApi::API do
  before(:each) do
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
      subject.stub(:url_for).and_return('/url')
    end
    
    context "called with a token parameter" do
      it "puts it into args" do
        subject.should_receive(:url_for).with('apiMethod', :some => :params, :access_token => 'token')
        subject.call('apiMethod', {:some => :params}, 'token')
      end
    end
    
    it "returns the response body" do
      subject.call('apiMethod').should == @result
    end
  end
  
  describe ".url_for" do
    it "converts the arguments and sends them to connection.build_url" do
      args = stub("Arguments")
      flat_args = stub("Flat arguments")
      
      VkontakteApi::Utils.should_receive(:flatten_arguments).with(args).and_return(flat_args)
      @connection.should_receive(:build_url).with(:method_name, flat_args)
      VkontakteApi::API.send(:url_for, :method_name, args)
    end
  end
end
