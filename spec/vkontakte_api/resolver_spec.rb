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
      allow(@resolver).to receive(:token).and_return(@token)
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
      allow(@resolver).to receive(:token).and_return(@token)
    end
    
    let(:resolver) { @resolver.resolver }
    
    it "returns a Hashie::Mash with a name and a token" do
      expect(resolver.name).to  eq(@name)
      expect(resolver.token).to eq(@token)
    end
    
    it "caches the result" do
      @mash = double("Mash", name: @name, token: @token)
      expect(Hashie::Mash).to receive(:new).once.and_return(@mash)
      5.times { @resolver.resolver }
    end
  end
end
