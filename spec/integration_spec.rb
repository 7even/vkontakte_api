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
    
    it "get users" do
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
    
    it "get groups" do
      groups = @vk.groups.get
      groups.should include(1)
    end
  end if ENV['TOKEN']
  
  describe "requests with camelCase and predicate methods" do
    before(:each) do
      @vk = VkontakteApi::Client.new(ENV['TOKEN'])
    end
    
    it "convert method names to vk.com format" do
      @vk.is_app_user?.should be_true
    end
  end if ENV['TOKEN']
  
  describe "requests with blocks" do
    before(:each) do
      @vk = VK::Client.new
    end
    
    it "map the result with a block" do
      users = @vk.users.get(:uid => 1) do |user|
        "#{user.last_name} #{user.first_name}"
      end
      
      users.first.should == 'Дуров Павел'
    end
  end
  
  after(:all) do
    VkontakteApi.reset
  end
end
