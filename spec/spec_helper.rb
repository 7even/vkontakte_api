require 'vkontakte_api'
require 'pry'
require 'awesome_print'
require_relative './support/mechanized_authorization'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end

RSpec::Matchers.define :log_requests do
  match do |logger|
    logger.log_requests?
  end
end

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
