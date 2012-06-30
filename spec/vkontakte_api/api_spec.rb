require 'spec_helper'

describe VkontakteApi::API do
  describe ".call" do
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
  
  describe ".flatten_arguments" do
    before(:each) do
      @args = {
        :field        => 'value',
        :access_token => 'some_token'
      }
    end
    
    context "with flat arguments" do
      it "leaves them untouched" do
        subject.send(:flatten_arguments, @args).should == @args
      end
    end
    
    context "with array arguments" do
      before(:each) do
        @args_with_array = @args.merge(:array_arg => [1, 2, 3])
      end
      
      it "joins them with a comma" do
        flat_arguments = subject.send(:flatten_arguments, @args_with_array)
        flat_arguments.should == @args.merge(:array_arg => '1,2,3')
      end
    end
  end
end
