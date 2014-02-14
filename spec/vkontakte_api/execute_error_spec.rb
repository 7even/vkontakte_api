require 'spec_helper'

describe VkontakteApi::ExecuteError do
  let(:errors_data) do
    [
      Hashie::Mash.new(
        method: 'wall.get',
        error_code: 100,
        error_msg: 'One of the parameters specified was missing or invalid: owner_id not integer'
      )
    ]
  end

  describe "#message" do
    let(:error) { VkontakteApi::ExecuteError.new(errors_data) }

    it "returns all needed data about an error" do
      message = 'VKontakte returned an errors:'
      message << "\n 1) Code 100: 'One of the parameters specified was missing or invalid: owner_id not integer'"
      message << "\n    after calling method 'wall.get'."

      expect {
        raise error
      }.to raise_error(error.class, message)
    end
  end
end
