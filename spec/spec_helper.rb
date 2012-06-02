require 'vkontakte_api'
require 'pry'

RSpec::Matchers.define :log_errors do
  match do |logger|
    logger.log_errors?
  end
end

RSpec::Matchers.define :log_responses do
  match do |logger|
    logger.log_responses?
  end
end
