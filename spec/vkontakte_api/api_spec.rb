require 'spec_helper'

describe VkontakteApi::API do
  before(:each) do
    @method_name =  'apiMethod'
    @args = {
      field:        'value',
      access_token: 'some_token'
    }
  end
  
  describe ".call" do
    before(:each) do
      @url = stub("URL")
      VkontakteApi::API.stub(:url_for).and_return(@url)
      
      @connection = stub("Faraday connection")
      Faraday.stub(:new).and_return(@connection)
      
      body = stub("Response body")
      response = stub("Response", :body => body)
      @connection.stub(:get).and_return(response)
      
      @result = stub("Result")
      JSON.stub(:load).and_return(@result)
    end
    
    it "calls the url from .url_for" do
      @connection.should_receive(:get).with(@url)
      VkontakteApi::API.call('apiMethod')
    end
    
    it "returns the response body" do
      VkontakteApi::API.call('apiMethod').should == @result
    end
  end
  
  describe ".url_for" do
    it "constructs a valid VK API url" do
      url = VkontakteApi::API.send(:url_for, @method_name, @args)
      url.should == '/method/apiMethod?field=value&access_token=some_token'
    end
  end
end
