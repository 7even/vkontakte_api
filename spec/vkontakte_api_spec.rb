require 'spec_helper'

describe VkontakteApi do
  describe ".configure" do
    VkontakteApi::Configuration::OPTION_NAMES.each do |name|
      it "sets the #{name}" do
        VkontakteApi.configure do |config|
          config.send("#{name}=", name)
        end
        
        expect(VkontakteApi.send(name)).to eq(name)
      end
    end
    
    after(:each) do
      VkontakteApi.reset
    end
  end
  
  describe ".register_alias" do
    before(:each) do
      VkontakteApi.register_alias
    end
    
    it "creates a VK alias" do
      expect(VK).to eq(VkontakteApi)
    end
    
    after(:each) do
      VkontakteApi.unregister_alias
    end
  end
  
  describe ".unregister_alias" do
    context "after calling .register_alias" do
      before(:each) do
        VkontakteApi.register_alias
      end
      
      it "removes the alias" do
        VkontakteApi.unregister_alias
        expect { VK }.to raise_error(NameError)
      end
    end
    
    context "without creating an alias" do
      it "does nothing" do
        expect(Object).not_to receive(:remove_const)
        VkontakteApi.unregister_alias
      end
    end
  end
end
