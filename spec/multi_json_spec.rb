require 'spec_helper'

describe MultiJson do
  it 'uses Oj' do
    expect(MultiJson.adapter.to_s).to eq('MultiJson::Adapters::Oj')
  end unless defined?(JRUBY_VERSION)
end
