require 'spec_helper'

describe VkontakteApi::ExecuteError do
  let(:errors_data) do
    [
      Hashie::Mash.new(
        method:     'status.get',
        error_code: 15,
        error_msg:  'Access denied: no access to call this method'
      ),
      Hashie::Mash.new(
        method:     'photos.get',
        error_code: 100,
        error_msg:  'One of the parameters specified was missing or invalid: album_id is invalid'
      ),
      Hashie::Mash.new(
        method:     'execute',
        error_code: 100,
        error_msg:  'One of the parameters specified was missing or invalid: album_id is invalid'
      )
    ]
  end

  subject { VkontakteApi::ExecuteError.new(errors_data) }

  describe '#message' do
    it 'returns a description of all errors' do
      message = 'VKontakte returned the following errors:'
      message << "\n * Code 15: 'Access denied: no access to call this method'"
      message << "\n   after calling method 'status.get'."
      message << "\n * Code 100: 'One of the parameters specified was missing or invalid: album_id is invalid'"
      message << "\n   after calling method 'photos.get'."
      message << "\n * Code 100: 'One of the parameters specified was missing or invalid: album_id is invalid'"
      message << "\n   after calling method 'execute'."

      expect {
        raise subject
      }.to raise_error(subject.class, message)
    end
  end
end
