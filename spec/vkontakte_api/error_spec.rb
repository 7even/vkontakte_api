require 'spec_helper'

describe VkontakteApi::Error do
  let(:error_data) do
    Hashie::Mash.new(
      error_code:     5,
      error_msg:      'User authorization failed: invalid access_token.',
      request_params: [
        {
          key:   'oauth',
          value: '1'
        },
        {
          key:   'method',
          value: 'unknownMethod'
        },
        {
          key:   'access_token',
          value: '123'
        }
      ]
    )
  end
  
  describe "#message" do
    context "without parameters" do
      let(:error) { VkontakteApi::Error.new(error_data) }
      
      it "returns all needed data about an error" do
        message = 'VKontakte returned an error 5: \'User authorization failed: invalid access_token.\''
        message << ' after calling method \'unknownMethod\' without parameters.'
        
        expect {
          raise error
        }.to raise_error(error.class, message)
      end
    end
    
    context "with parameters" do
      let(:error) do
        error_data[:request_params] << Hashie::Mash.new(key: 'some', value: 'params')
        VkontakteApi::Error.new(error_data)
      end
      
      it "returns all needed data about an error" do
        message = 'VKontakte returned an error 5: \'User authorization failed: invalid access_token.\''
        message << ' after calling method \'unknownMethod\' with parameters {"some"=>"params"}.'
        
        expect {
          raise error
        }.to raise_error(error.class, message)
      end
    end
  end
end
