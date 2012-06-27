require 'spec_helper'

describe VkontakteApi::Method do
  it "should remember the namespace" do
    method = VkontakteApi::Method.new('name', :namespace => 'namespace')
    method.namespace.should == 'namespace'
  end
end
