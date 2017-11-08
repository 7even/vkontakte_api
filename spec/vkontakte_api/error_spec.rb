require 'spec_helper'

describe VkontakteApi::Error do
  let(:error_data) do
    Hashie::Mash.new(
      error_code: 5,
      error_msg:  'User authorization failed: invalid access_token.',
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

  subject { VkontakteApi::Error.new(error_data) }
  
  describe "#message" do
    context "without parameters" do
      it "returns all needed data about an error" do
        message = 'VKontakte returned an error 5: \'User authorization failed: invalid access_token.\''
        message << ' after calling method \'unknownMethod\' without parameters.'
        
        expect {
          raise subject
        }.to raise_error(subject.class, message)
      end
    end
    
    context "with parameters" do
      before(:each) do
        error_data[:request_params] << Hashie::Mash.new(key: 'some', value: 'params')
      end
      
      it "returns all needed data about an error" do
        message = 'VKontakte returned an error 5: \'User authorization failed: invalid access_token.\''
        message << ' after calling method \'unknownMethod\' with parameters {"some"=>"params"}.'
        
        expect {
          raise subject
        }.to raise_error(subject.class, message)
      end
    end

    context "for interval server error without request_params" do
      let(:error_data) do
        Hashie::Mash.new(error_code: 11, error_msg: 'Internal server error: Unknown error, try later')
      end

      it "returns all needed data about an error" do
        message = 'VKontakte returned an error 11: \'Internal server error: Unknown error, try later\''
        message << ' after calling method \'\' without parameters.'

        expect {
          raise subject
        }.to raise_error(subject.class, message)
      end
    end
  end
end
