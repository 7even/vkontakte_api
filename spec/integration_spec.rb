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
      config.api_version = '5.0'
    end
  end
  
  if MechanizedAuthorization.on?
    let(:vk) { MechanizedAuthorization.client }
      
    describe "authorized requests" do
      it "get groups" do
        expect(vk.groups.get.items).to include(1)
      end
    end
    
    describe "requests with camelCase and predicate methods" do
      it "convert method names to vk.com format" do
        expect(vk.is_app_user?).to be_truthy
      end
    end

    describe "requests with array arguments" do
      it "join arrays with a comma" do
        users = vk.users.get(uids: [1, 2, 3], fields: %w[first_name last_name screen_name])
        expect(users.first.screen_name).not_to be_empty
      end
    end
    
    describe "requests with blocks" do
      it "map the result with a block" do
        users = vk.users.get(uid: 1) do |user|
          "#{user.last_name} #{user.first_name}"
        end

        expect(users.first).not_to be_empty
      end
    end
  end

  describe "authorization" do
    context "with a scope" do
      it "returns a correct url" do
        url = VK.authorization_url(scope: %w[friends groups])
        expect(url).to include('scope=friends%2Cgroups')
      end
    end
  end
  
  after(:all) do
    VK.reset
    VK.unregister_alias
  end
end
