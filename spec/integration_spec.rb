# encoding: utf-8
require 'spec_helper'

describe "Integration" do
  before(:all) do
    # turn off all the logging
    VkontakteApi.configure do |config|
      config.log_requests  = false
      config.log_errors    = false
      config.log_responses = false
    end
  end
  
  describe "unauthorized requests" do
    before(:each) do
      @vk = VkontakteApi::Client.new
    end
    
    it "gets users" do
      user = @vk.users.get(:uid => 1).first
      user.uid.should        == 1
      user.last_name.should  == 'Дуров'
      user.first_name.should == 'Павел'
    end
  end
  
  describe "authorized requests" do
    before(:each) do
      @vk = VkontakteApi::Client.new(ENV['TOKEN'])
    end
    
    it "gets groups" do
      groups = @vk.groups.get
      groups.should include(1)
    end
  end if ENV['TOKEN']
end
