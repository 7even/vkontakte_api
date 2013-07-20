# encoding: utf-8
require 'spec_helper'

describe "Integration" do
  before(:all) do
    VkontakteApi.register_alias
    # turn off all the logging
    VK.configure do |config|
      config.log_requests  = false
      config.log_errors    = false
      config.log_responses = false
    end
  end
  
  describe "unauthorized requests" do
    before(:each) do
      @vk = VK::Client.new
    end
    
    it "get users" do
      user = @vk.users.get(uid: 1).first
      user.uid.should == 1
      user.last_name.should_not be_empty
      user.first_name.should_not be_empty
    end
    
    it "search newsfeed" do
      news = @vk.newsfeed.search(q: 'vk', count: 1)
      news.should be_a(Enumerable)
    end
  end
  
  if MechanizedAuthorization.on?
    describe "authorized requests" do
      before(:each) do
        @vk = MechanizedAuthorization.client
      end
      
      it "get groups" do
        groups = @vk.groups.get
        groups.should include(1)
      end
    end
    
    describe "requests with camelCase and predicate methods" do
      before(:each) do
        @vk = MechanizedAuthorization.client
      end
      
      it "convert method names to vk.com format" do
        @vk.is_app_user?.should be_true
      end
    end
  end
  
  describe "requests with array arguments" do
    before(:each) do
      @vk = VK::Client.new
    end
    
    it "join arrays with a comma" do
      users = @vk.users.get(uids: [1, 2, 3], fields: %w[first_name last_name screen_name])
      users.first.screen_name.should_not be_empty
    end
  end
  
  describe "requests with blocks" do
    before(:each) do
      @vk = VK::Client.new
    end
    
    it "map the result with a block" do
      users = @vk.users.get(uid: 1) do |user|
        "#{user.last_name} #{user.first_name}"
      end
      
      users.first.should_not be_empty
    end
  end
  
  describe "authorization" do
    context "with a scope" do
      it "returns a correct url" do
        VK.authorization_url(scope: %w[friends groups]).should include('scope=friends%2Cgroups')
      end
    end
  end
  
  after(:all) do
    VK.reset
    VK.unregister_alias
  end
end
