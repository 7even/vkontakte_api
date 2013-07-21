require 'spec_helper'

describe VkontakteApi::Resolver do
  before(:each) do
    @class = Class.new do
      include VkontakteApi::Resolver
      
      def initialize(name)
        @name = name
      end
    end
  end
  
  describe "#send" do
    before(:each) do
      @resolver = @class.new('trololo')
      @token = double("Token")
      @resolver.stub(:token).and_return(@token)
    end
    
    it "gets into #method_missing" do
      method = double("Method", call: nil)
      expect(@resolver).to receive(:method_missing).with(:send, message: 'hello')
      @resolver.send(message: 'hello')
    end
  end
  
  describe "#resolver" do
    before(:each) do
      @name     = double("Name")
      @resolver = @class.new(@name)
      @token    = double("Token")
      @resolver.stub(:token).and_return(@token)
    end
    
    it "returns a Hashie::Mash with a name and a token" do
      r = @resolver.resolver
      r.name.should  == @name
      r.token.should == @token
    end
    
    it "caches the result" do
      @mash = double("Mash", name: @name, token: @token)
      Hashie::Mash.should_receive(:new).once.and_return(@mash)
      5.times { @resolver.resolver }
    end
  end
end
