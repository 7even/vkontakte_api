require 'spec_helper'

describe VkontakteApi::Method do
  describe "#call" do
    before(:each) do
      @full_name = stub("Full method name")
      @args      = stub("Method arguments")
      @token     = stub("Access token")
      
      @method = VkontakteApi::Method.new('some_name')
      @method.stub(:full_name).and_return(@full_name)
      @method.stub(:token).and_return(@token)
      VkontakteApi::Result.stub(:process)
    end
    
    it "calls API.call with full name, args and token" do
      VkontakteApi::API.should_receive(:call).with(@full_name, @args, @token)
      @method.call(@args)
    end
    
    it "sends the response to Result.process" do
      response = stub("VK response")
      VkontakteApi::API.stub(:call).and_return(response)
      type = stub("Type")
      @method.stub(:type).and_return(type)
      
      VkontakteApi::Result.should_receive(:process).with(response, type, nil)
      @method.call(@args)
    end
  end
  
  describe "#full_name" do
    before(:each) do
      resolver = Hashie::Mash.new(:name => 'name_space')
      @name = 'name'
      @method = VkontakteApi::Method.new(@name, :resolver => resolver)
    end
    
    it "sends each part to #camelize" do
      @method.send(:full_name).should == 'nameSpace.name'
    end
  end
  
  describe "#type" do
    context "with a usual name" do
      it "returns :anything" do
        method = VkontakteApi::Method.new('get')
        method.send(:type).should == :anything
      end
    end
    
    context "with a predicate name" do
      it "returns :boolean" do
        method = VkontakteApi::Method.new('is_app_user?')
        method.send(:type).should == :boolean
      end
    end
  end
end
