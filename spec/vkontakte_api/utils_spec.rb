require 'spec_helper'

describe VkontakteApi::Utils do
  describe ".flatten_arguments" do
    let(:arg1) { double("First argument") }
    let(:arg2) { double("Second argument") }
    let(:flat_arg1) { double("Flattened first argument") }
    let(:flat_arg2) { double("Flattened second argument") }
    
    before(:each) do
      allow(VkontakteApi::Utils).to receive(:flatten_argument) do |arg|
        case arg
        when arg1 then flat_arg1
        when arg2 then flat_arg2
        end
      end
    end
    
    it "sends each value to .flatten_argument" do
      flat_arguments = VkontakteApi::Utils.flatten_arguments(arg1: arg1, arg2: arg2)
      expect(flat_arguments).to eq(arg1: flat_arg1, arg2: flat_arg2)
    end
  end
  
  describe ".flatten_argument" do
    context "with a flat argument" do
      let(:argument) { :flat }
      
      it "leaves it untouched" do
        result = subject.send(:flatten_argument, argument)
        expect(result).to eq(argument)
      end
    end
    
    context "with an array argument" do
      let(:array_argument) { [1, 2, 3] }
      
      it "joins the elements with a comma" do
        flat_argument = subject.send(:flatten_argument, array_argument)
        expect(flat_argument).to eq('1,2,3')
      end
    end
  end
end
