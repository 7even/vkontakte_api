require 'spec_helper'

describe VkontakteApi::Utils do
  describe ".flatten_arguments" do
    before(:each) do
      @arg1 = stub("First argument")
      @arg2 = stub("Second argument")
      @flat_arg1 = stub("Flattened first argument")
      @flat_arg2 = stub("Flattened second argument")
      
      VkontakteApi::Utils.stub(:flatten_argument) do |arg|
        case arg
        when @arg1 then @flat_arg1
        when @arg2 then @flat_arg2
        end
      end
    end
    
    it "sends each value to .flatten_argument" do
      flat_arguments = VkontakteApi::Utils.flatten_arguments(:arg1 => @arg1, :arg2 => @arg2)
      flat_arguments.should == {:arg1 => @flat_arg1, :arg2 => @flat_arg2}
    end
  end
  
  describe ".flatten_argument" do
    context "with a flat argument" do
      before(:each) do
        @argument = :flat
      end
      
      it "leaves it untouched" do
        subject.send(:flatten_argument, @argument).should == @argument
      end
    end
    
    context "with an array argument" do
      before(:each) do
        @array_argument = [1, 2, 3]
      end
      
      it "joins the elements with a comma" do
        flat_argument = subject.send(:flatten_argument, @array_argument)
        flat_argument.should == '1,2,3'
      end
    end
  end
end
