require 'spec_helper'

describe VkontakteApi::Resolvable do
  before(:each) do
    @class = Class.new do
      include VkontakteApi::Resolvable
    end
  end
  
  describe "#initialize" do
    it "should save name and token" do
      name   = stub("Name")
      token  = stub("Token")
      object = @class.new(name, :token => token)
      
      object.name.should  == name
      object.token.should == token
    end
  end
end
