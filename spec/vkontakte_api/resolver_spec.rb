require 'spec_helper'

describe VkontakteApi::Resolver do
  describe "#method_missing" do
    before(:each) do
      @result = stub("API result")
      @result.stub(:respond_to?).and_return(false)
      
      VkontakteApi::API.stub(:call).and_return(@result)
      @args = {:arg_name => 'arg_value'}
      @token = stub("Access token")
    end
    
    context "with a nil @namespace" do
      before(:each) do
        VkontakteApi::Resolver.stub(:vk_method_name).and_return('apiMethod')
        @resolver = VkontakteApi::Resolver.new(:access_token => @token)
      end
      
      context "with method_name not from namespaces" do
        it "calls #vk_method_name with method name and nil namespace" do
          VkontakteApi::Resolver.should_receive(:vk_method_name).with('api_method', nil)
          @resolver.api_method
        end
        
        it "calls #api_call with full VK method name and access_token" do
          @args.should_receive(:[]=).with(:access_token, @token)
          VkontakteApi::API.should_receive(:call).with('apiMethod', @args)
          @resolver.api_method(@args).should == @result
        end
      end
      
      context "with method_name from namespaces" do
        it "return a new resolver with the corresponding @namespace" do
          new_resolver = @resolver.friends
          new_resolver.should be_a(VkontakteApi::Resolver)
          new_resolver.namespace.should == 'friends'
        end
      end
      
      context "without a token" do
        before(:each) do
          @resolver = VkontakteApi::Resolver.new
        end
        
        it "calls #api_call with full VK method name but without a token" do
          @args.should_not_receive(:[]=).with(:access_token, anything)
          VkontakteApi::API.should_receive(:call).with('apiMethod', @args)
          @resolver.api_method(@args).should == @result
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
    
    it "returns the result of #yield_result" do
      resolver = VkontakteApi::Resolver.new
      yielded_result = stub("Yielded result")
      resolver.should_receive(:yield_result).with(@result, :anything, nil).and_return(yielded_result)
      resolver.api_method.should == yielded_result
    end
  end
  
  describe "#yield_result" do
    before(:each) do
      @resolver = VkontakteApi::Resolver.new
    end
    
    context "with a non-enumerable result" do
      before(:each) do
        @result = stub("result")
        @type = stub("Type")
        @typecasted_value = stub("Typecasted value")
        @resolver.stub(:typecast).and_return(@typecasted_value)
      end
      
      it "returns #typecast-ed value" do
        @resolver.should_receive(:typecast).with(@result, @type).and_return(@typecasted_value)
        @resolver.send(:yield_result, @result, @type, nil).should == @typecasted_value
      end
      
      context "when block_given?" do
        it "yields the #typecast-ed value and returns the result of the block" do
          block_result = stub("Block result")
          @typecasted_value.should_receive(:result_method).and_return(block_result)
          block = proc(&:result_method)
          
          @resolver.send(:yield_result, @result, @type, block).should == block_result
        end
      end
    end
    
    context "with an enumerable result" do
      before(:each) do
        @element1 = stub("First element")
        @element2 = stub("Second element")
        @enumerable_result = [@element1, @element2]
      end
      
      it "returns the untouched value" do
        @resolver.send(:yield_result, @enumerable_result, :anything, nil).should == @enumerable_result
      end
      
      context "when block_given?" do
        it "yields each element untouched to the block" do
          result1 = stub("First element after result_method")
          result2 = stub("Second element after result_method")
          @element1.should_receive(:result_method).and_return(result1)
          @element2.should_receive(:result_method).and_return(result2)
          block = proc(&:result_method)
          
          @resolver.send(:yield_result, @enumerable_result, :anything, block).should == [result1, result2]
        end
      end
    end
  end
  
  describe ".vk_method_name" do
    context "without a namespace" do
      it "returns 'methodName'" do
        VkontakteApi::Resolver.vk_method_name('api_method').should == 'apiMethod'
      end
    end
    
    context "with a namespace" do
      it "returns 'namespace.methodName'" do
        VkontakteApi::Resolver.vk_method_name('api_method', 'namespace').should == 'namespace.apiMethod'
      end
    end
    
    context "with several upcase letters in row" do
      it "just upcases the first letter of each word" do
        VkontakteApi::Resolver.vk_method_name('get_SMS_prefix').should == 'getSMSPrefix'
      end
    end
    
    it "returns method name without unneeded characters" do
      VkontakteApi::Resolver.vk_method_name('is9_it_w%orking?').should == 'isItWorking'
    end
  end
  
  describe ".type" do
    context "with a usual method name" do
      it "returns :anything as a type" do
        VkontakteApi::Resolver.type('api_method').should == :anything
      end
    end
    
    context "with a predicate method name" do
      it "returns :boolean as a type" do
        VkontakteApi::Resolver.type('is_it_working?').should == :boolean
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
