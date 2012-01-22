require 'spec_helper'

class Configurable
  extend VkontakteApi::Configuration
end

describe VkontakteApi::Configuration do
  describe "#configure" do
    it "yields self" do
      Configurable.should_receive(:some_method)
      Configurable.configure do |config|
        config.some_method
      end
    end
    
    it "returns self" do
      Configurable.configure.should == Configurable
    end
  end
end
