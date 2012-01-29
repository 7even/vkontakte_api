require 'spec_helper'

describe VkontakteApi::Resolver do
  describe "#method_missing" do
    before(:each) do
      @result = stub("API result")
      VkontakteApi::API.stub(:call).and_return(@result)
      @args = {:arg_name => 'arg_value'}
      @token = stub("Access token")
    end
    
    context "with a nil @namespace" do
      before(:each) do
        @resolver = VkontakteApi::Resolver.new(:access_token => @token)
      end
      
      context "with method_name not from NAMESPACES" do
        before(:each) do
          VkontakteApi::Resolver.stub(:vk_method_name).and_return(['apiMethod', :anything])
        end
        
        it "calls #vk_method_name with method name and nil namespace" do
          VkontakteApi::Resolver.should_receive(:vk_method_name).with('api_method', nil)
          @resolver.api_method
        end
        
        it "calls #api_call with full VK method name" do
          full_args = @args.merge(:access_token => @token)
          VkontakteApi::API.should_receive(:call).with('apiMethod', full_args)
          @resolver.api_method(@args).should == @result
        end
      end
      
      context "with method_name from NAMESPACES" do
        it "return a new resolver with the corresponding @namespace" do
          new_resolver = @resolver.friends
          new_resolver.should be_a(VkontakteApi::Resolver)
          new_resolver.namespace.should == 'friends'
        end
      end
    end
    
    context "with a non-nil @namespace" do
      before(:each) do
        @resolver = VkontakteApi::Resolver.new(:namespace => 'friends')
        VkontakteApi::Resolver.stub(:vk_method_name).and_return('friends.apiMethod')
      end
      
      it "calls #vk_method_name with method name and @namespace" do
        VkontakteApi::Resolver.should_receive(:vk_method_name).with('api_method', 'friends')
        @resolver.api_method
      end
    end
    
    it "calls #typecast with the API result and method type" do
      resolver = VkontakteApi::Resolver.new
      type = stub("Type")
      VkontakteApi::Resolver.stub(:vk_method_name).and_return([:method_name, type])
      
      resolver.should_receive(:typecast).with(@result, type)
      resolver.method_name
    end
    
    it "returns #typecast-ed value" do
      resolver = VkontakteApi::Resolver.new
      typecasted_value = stub("Typecasted value")
      resolver.stub(:typecast).and_return(typecasted_value)
      
      resolver.method_name.should == typecasted_value
    end
  end
  
  describe ".vk_method_name" do
    context "with a usual method name" do
      context "without a namespace" do
        it "returns 'methodName'" do
          VkontakteApi::Resolver.vk_method_name(:api_method).first.should == 'apiMethod'
        end
      end
      
      context "with a namespace" do
        it "returns 'namespace.methodName'" do
          VkontakteApi::Resolver.vk_method_name(:api_method, 'namespace').first.should == 'namespace.apiMethod'
        end
      end
      
      it "returns :anything as a type" do
        VkontakteApi::Resolver.vk_method_name(:api_method).last.should == :anything
      end
    end
    
    context "with a predicate method name" do
      it "returns method name without '?'" do
        VkontakteApi::Resolver.vk_method_name(:is_it_working?).first.should == 'isItWorking'
      end
      
      it "returns :boolean as a type" do
        VkontakteApi::Resolver.vk_method_name(:is_it_working?).last.should == :boolean
      end
    end
  end
  
  describe "#typecast" do
    before(:each) do
      @resolver = VkontakteApi::Resolver.new
    end
    
    context "with an :anything type" do
      it "returns it's argument untouched" do
        @resolver.send(:typecast, :some_arg, :anything).should == :some_arg
      end
    end
    
    context "with a :boolean type" do
      context "and zero result" do
        it "returns false" do
          @resolver.send(:typecast, '0', :boolean).should == false
        end
      end
      
      context "and non-zero parameter" do
        it "returns true" do
          @resolver.send(:typecast, '1', :boolean).should == true
        end
      end
    end
  end
end
