require 'spec_helper'

describe VkontakteApi::Method do
  describe "#full_name" do
    before(:each) do
      resolver = Hashie::Mash.new(:name => 'name_space')
      @name = 'name'
      @method = VkontakteApi::Method.new(@name, :resolver => resolver)
    end
    
    it "sends each part to #camelize" do
      @method.send(:full_name).should == 'nameSpace.name'
    end
  end
  
  describe "#type" do
    context "with a usual name" do
      it "returns :anything" do
        method = VkontakteApi::Method.new('get')
        method.send(:type).should == :anything
      end
    end
    
    context "with a predicate name" do
      it "returns :boolean" do
        method = VkontakteApi::Method.new('is_app_user?')
        method.send(:type).should == :boolean
      end
    end
  end
end
