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
  
  describe "#method_missing" do
    before(:each) do
      @resolver = @class.new(:trololo)
      @token = stub("Token")
      @resolver.stub(:token).and_return(@token)
    end
    
    context "called with a namespace" do
      it "returns a Namespace instance" do
        namespace = @resolver.users
        namespace.should be_a(VkontakteApi::Namespace)
      end
    end
    
    context "called with a method" do
      before(:each) do
        @result = stub("Result")
        @method = stub("Method", call: @result)
        VkontakteApi::Method.stub(:new).and_return(@method)
      end
      
      it "creates a Method instance" do
        VkontakteApi::Method.should_receive(:new).with('get', resolver: @resolver.resolver)
        @resolver.get(id: 1)
      end
      
      it "calls Method#call and returns the result" do
        @method.should_receive(:call).with(id: 1)
        @resolver.get(id: 1).should == @result
      end
    end
  end
  
  describe "#send" do
    before(:each) do
      @resolver = @class.new('trololo')
      @token = stub("Token")
      @resolver.stub(:token).and_return(@token)
    end
    
    it "gets into #method_missing" do
      method = stub("Method", call: nil)
      VkontakteApi::Method.should_receive(:new).with('send', resolver: @resolver.resolver).and_return(method)
      @resolver.send(message: 'hello')
    end
  end
  
  describe "#resolver" do
    before(:each) do
      @name     = stub("Name")
      @resolver = @class.new(@name)
      @token    = stub("Token")
      @resolver.stub(:token).and_return(@token)
    end
    
    it "returns a Hashie::Mash with a name and a token" do
      r = @resolver.resolver
      r.name.should  == @name
      r.token.should == @token
    end
    
    it "caches the result" do
      @mash = stub("Mash", name: @name, token: @token)
      Hashie::Mash.should_receive(:new).once.and_return(@mash)
      5.times { @resolver.resolver }
    end
  end
  
  describe ".namespaces" do
    before(:each) do
      VkontakteApi::Resolver.instance_variable_set(:@namespaces, nil)
    end
    
    context "on first call" do
      it "loads namespaces from a file" do
        filename = stub("Filename")
        File.should_receive(:expand_path).and_return(filename)
        namespaces = stub("Namespaces list")
        YAML.should_receive(:load_file).with(filename).and_return(namespaces)
        
        VkontakteApi::Resolver.namespaces
      end
    end
    
    context "on subsequent calls" do
      before(:each) do
        VkontakteApi::Resolver.namespaces
      end
      
      it "returns the cached list" do
        YAML.should_not_receive(:load_file)
        VkontakteApi::Resolver.namespaces
      end
    end
  end
end
