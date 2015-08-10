require 'spec_helper'

describe MultiJson do
  unless defined?(JRUBY_VERSION)
    it "should use Oj" do
      expect(MultiJson.adapter.to_s).to eq("MultiJson::Adapters::Oj")
    end
  end
end