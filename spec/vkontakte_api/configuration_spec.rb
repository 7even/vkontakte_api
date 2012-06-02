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
  
  describe "#reset" do
    it "sets all options to their default values" do
      Configurable.reset
      Configurable.app_id.should be_nil
      Configurable.app_secret.should be_nil
      Configurable.adapter.should == VkontakteApi::Configuration::DEFAULT_ADAPTER
      
      Configurable.logger.should be_a(Logger)
      Configurable.should log_errors
      Configurable.should_not log_responses
    end
  end
end
