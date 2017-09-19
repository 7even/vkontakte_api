require 'spec_helper'

describe VkontakteApi::Result do
  describe ".process" do
    let(:response) { double("Response") }
    let(:result) { double("Result") }
    
    before(:each) do
      allow(subject).to receive(:extract_result).and_return(result)
    end
    
    it "calls .extract_result passing it the response" do
      expect(subject).to receive(:extract_result).with(response)
      subject.process(response, :anything, nil)
    end
    
    context "with a non-enumerable result" do
      let(:type) { double("Type") }
      let(:typecasted_value) { double("Typecasted value") }
      
      before(:each) do
        allow(subject).to receive(:typecast).and_return(typecasted_value)
      end
      
      it "returns #typecast-ed value" do
        expect(subject).to receive(:typecast).with(result, type).and_return(typecasted_value)
        expect(subject.process(result, type, nil)).to eq(typecasted_value)
      end
      
      context "when block_given?" do
        it "yields the #typecast-ed value and returns the result of the block" do
          block_result = double("Block result")
          expect(typecasted_value).to receive(:result_method).and_return(block_result)
          block = proc(&:result_method)
          
          expect(subject.process(response, type, block)).to eq(block_result)
        end
      end
    end
    
    context "with an enumerable result" do
      let(:element1) { double("First element") }
      let(:element2) { double("Second element") }
      let(:enumerable_result) { [element1, element2] }
      
      before(:each) do
        allow(subject).to receive(:extract_result).and_return(enumerable_result)
      end
      
      it "returns the untouched value" do
        expect(subject.process(enumerable_result, :anything, nil)).to eq(enumerable_result)
      end
      
      context "when block_given?" do
        it "yields each element untouched to the block" do
          result1 = double("First element after result_method")
          result2 = double("Second element after result_method")
          expect(element1).to receive(:result_method).and_return(result1)
          expect(element2).to receive(:result_method).and_return(result2)
          block = proc(&:result_method)
          
          expect(subject.process(enumerable_result, :anything, block)).to eq([result1, result2])
        end
      end
    end
  end
  
  describe ".extract_result" do
    let(:result_response) do
      { 'key' => 'value' }
    end
    
    let(:result_error) do
      {
        'request_params' => [
          {
            'key'   => 'error',
            'value' => 'description'
          }
        ]
      }
    end

    let(:response_error_for_execute) do
      {
        'response'=>'', 
        'execute_errors'=>[
          {'method'=>'groups.getMembers', 'error_code'=>15, 'error_msg'=>'Access denied: you should be group moderator'}, 
          {'method'=>'execute', 'error_code'=>15, 'error_msg'=>'Access denied: you should be group moderator'}
        ]
      }
    end
    
    context "with a successful response" do
      let(:result) { Hashie::Mash.new(response: result_response) }
      
      it "returns the response part" do
        expect(subject.send(:extract_result, result)).to eq(result_response)
      end
    end
    
    context "with an error response" do
      let(:result) { Hashie::Mash.new(error: result_error) }
      
      it "raises a VkontakteApi::Error" do
        expect {
          subject.send(:extract_result, result)
        }.to raise_error(VkontakteApi::Error)
      end
    end

    context "with an error response for execute method" do
      let(:result) { Hashie::Mash.new(response_error_for_execute) }

      it "raises a VkontakteApi::Error" do
        expect {
          subject.send(:extract_result, result)
        }.to raise_error(VkontakteApi::Error)
      end
    end
  end
  
  describe ".typecast" do
    context "with an :anything type" do
      it "returns it's argument untouched" do
        expect(subject.send(:typecast, :some_arg, :anything)).to eq(:some_arg)
      end
    end
    
    context "with a :boolean type" do
      context "and zero result" do
        it "returns false" do
          expect(subject.send(:typecast, '0', :boolean)).to eq(false)
        end
      end
      
      context "and non-zero parameter" do
        it "returns true" do
          expect(subject.send(:typecast, '1', :boolean)).to eq(true)
        end
      end
    end
  end
end
