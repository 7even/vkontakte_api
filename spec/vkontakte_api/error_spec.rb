require 'spec_helper'

describe VkontakteApi::Error do
  before(:each) do
    @e = VkontakteApi::Error.new(
      :error_code      => 5,
      :error_msg       => 'User authorization failed: invalid access_token.',
      :request_params  => [
        {
          :key   => 'oauth',
          :value => '1'
        },
        {
          :key   => 'method',
          :value => 'unknownMethod'
        },
        {
          :key   => 'some',
          :value => 'params'
        },
        {
          :key   => 'access_token',
          :value => '123'
        }
      ]
    )
  end
  
  describe "#message" do
    it "returns all needed data about an error" do
      message = 'VKontakte returned an error 5: \'User authorization failed: invalid access_token.\' after calling method \'unknownMethod\' with parameters {"some"=>"params"}.'
      expect {
        raise @e
      }.to raise_error(@e.class, message)
    end
  end
end
