require 'spec_helper'

describe VkontakteApi::Resolvable do
  before(:each) do
    @class = Class.new do
      include VkontakteApi::Resolvable
    end
  end
  
  describe "#initialize" do
    it "should save name and resolver" do
      name     = stub("Name")
      token    = stub("Token")
      resolver = Hashie::Mash.new(:token => token)
      
      resolvable = @class.new(name, :resolver => resolver)
      resolvable.name.should  == name
      resolvable.token.should == token
    end
  end
end
