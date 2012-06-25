require 'spec_helper'

describe VkontakteApi::API do
  describe ".call" do
    before(:each) do
      @result_response  = {'key' => 'value'}
      @result_error     = {'request_params' => [{'key' => 'error', 'value' => 'description'}]}
      
      @result = {'response' => @result_response}
      
      @connection = Faraday.new do |builder|
        builder.response :mashify
        builder.response :json, :preserve_raw => true
        builder.adapter  :test do |stub|
          stub.get('/url') do
            [200, {}, Oj.dump(@result)]
          end
        end
      end
      VkontakteApi::API.stub(:connection).and_return(@connection)
      
      VkontakteApi::API.stub(:url_for).and_return('/url')
    end
    
    context "with a successful response" do
      it "returns the response body" do
        VkontakteApi::API.call('apiMethod').should == @result_response
      end
    end
    
    context "with an error response" do
      before(:each) do
        @result['error'] = @result_error
      end
      
      it "raises a VkontakteApi::Error" do
        expect {
          VkontakteApi::API.call('apiMethod')
        }.to raise_error(VkontakteApi::Error)
      end
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
        VkontakteApi::API.send(:flatten_arguments, @args).should == @args
      end
    end
    
    context "with array arguments" do
      before(:each) do
        @args_with_array = @args.merge(:array_arg => [1, 2, 3])
      end
      
      it "joins them with a comma" do
        flat_arguments = VkontakteApi::API.send(:flatten_arguments, @args_with_array)
        flat_arguments.should == @args.merge(:array_arg => '1,2,3')
      end
    end
  end
end
