require 'spec_helper'

describe VkontakteApi::Result do
  describe ".process" do
    before(:each) do
      @response = double("Response")
      @result = double("Result")
      subject.stub(:extract_result).and_return(@result)
    end
    
    it "calls .extract_result passing it the response" do
      subject.should_receive(:extract_result).with(@response)
      subject.process(@response, @type, nil)
    end
    
    context "with a non-enumerable result" do
      before(:each) do
        @type = double("Type")
        @typecasted_value = double("Typecasted value")
        subject.stub(:typecast).and_return(@typecasted_value)
      end
      
      it "returns #typecast-ed value" do
        subject.should_receive(:typecast).with(@result, @type).and_return(@typecasted_value)
        subject.send(:process, @result, @type, nil).should == @typecasted_value
      end
      
      context "when block_given?" do
        it "yields the #typecast-ed value and returns the result of the block" do
          block_result = double("Block result")
          @typecasted_value.should_receive(:result_method).and_return(block_result)
          block = proc(&:result_method)
          
          subject.send(:process, @response, @type, block).should == block_result
        end
      end
    end
    
    context "with an enumerable result" do
      before(:each) do
        @element1 = double("First element")
        @element2 = double("Second element")
        @enumerable_result = [@element1, @element2]
        subject.stub(:extract_result).and_return(@enumerable_result)
      end
      
      it "returns the untouched value" do
        subject.send(:process, @enumerable_result, :anything, nil).should == @enumerable_result
      end
      
      context "when block_given?" do
        it "yields each element untouched to the block" do
          result1 = double("First element after result_method")
          result2 = double("Second element after result_method")
          @element1.should_receive(:result_method).and_return(result1)
          @element2.should_receive(:result_method).and_return(result2)
          block = proc(&:result_method)
          
          subject.send(:process, @enumerable_result, :anything, block).should == [result1, result2]
        end
      end
    end
  end
  
  describe ".extract_result" do
    before(:each) do
      @result_response  = { 'key' => 'value' }
      @result_error     = { 'request_params' => [{ 'key' => 'error', 'value' => 'description' }] }
    end
    
    context "with a successful response" do
      before(:each) do
        @result = Hashie::Mash.new(response: @result_response)
      end
      
      it "returns the response part" do
        subject.send(:extract_result, @result).should == @result_response
      end
    end
    
    context "with an error response" do
      before(:each) do
        @result = Hashie::Mash.new(error: @result_error)
      end
      
      it "raises a VkontakteApi::Error" do
        expect {
          subject.send(:extract_result, @result)
        }.to raise_error(VkontakteApi::Error)
      end
    end
  end
  
  describe ".typecast" do
    context "with an :anything type" do
      it "returns it's argument untouched" do
        subject.send(:typecast, :some_arg, :anything).should == :some_arg
      end
    end
    
    context "with a :boolean type" do
      context "and zero result" do
        it "returns false" do
          subject.send(:typecast, '0', :boolean).should == false
        end
      end
      
      context "and non-zero parameter" do
        it "returns true" do
          subject.send(:typecast, '1', :boolean).should == true
        end
      end
    end
  end
end
