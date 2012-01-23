require 'spec_helper'

describe VkontakteApi::Resolver do
  describe "#method_missing" do
    before(:each) do
      VkontakteApi::API.stub(:call)
      @args = {arg_name: 'arg_value'}
    end
    
    context "with a nil @namespace" do
      before(:each) do
        @resolver = VkontakteApi::Resolver.new
      end
      
      context "with method_name not from NAMESPACES" do
        before(:each) do
          VkontakteApi::Resolver.stub(:vk_method_name).and_return('apiMethod')
        end
        
        it "calls #vk_method_name with method name and nil namespace" do
          VkontakteApi::Resolver.should_receive(:vk_method_name).with('api_method', nil)
          @resolver.api_method
        end
        
        it "calls #api_call with full VK method name" do
          VkontakteApi::API.should_receive(:call).with('apiMethod', @args)
          @resolver.api_method(@args)
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
        @resolver = VkontakteApi::Resolver.new('friends')
        VkontakteApi::Resolver.stub(:vk_method_name).and_return('friends.apiMethod')
      end
      
      it "calls #vk_method_name with method name and @namespace" do
        VkontakteApi::Resolver.should_receive(:vk_method_name).with('api_method', 'friends')
        @resolver.api_method
      end
    end
  end
  
  describe ".vk_method_name" do
    context "without a namespace" do
      it "returns 'methodName'" do
        VkontakteApi::Resolver.vk_method_name(:api_method).should == 'apiMethod'
      end
    end
    
    context "with a namespace" do
      it "returns 'namespace.methodName'" do
        VkontakteApi::Resolver.vk_method_name(:api_method, 'namespace').should == 'namespace.apiMethod'
      end
    end
  end
end
