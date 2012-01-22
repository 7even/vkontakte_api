require 'spec_helper'

describe VkontakteApi do
  describe ".configure" do
    VkontakteApi::Configuration::OPTION_NAMES.each do |name|
      it "should set the #{name}" do
        VkontakteApi.configure do |config|
          config.send("#{name}=", name)
          VkontakteApi.send(name).should == name
        end
      end
    end
  end
end
