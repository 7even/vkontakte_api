require 'spec_helper'

describe VkontakteApi::Method do
  describe "#call" do
    let(:full_name) { double("Full method name") }
    let(:args) { double("Method arguments") }
    let(:token) { double("Access token") }
    
    let(:method) do
      VkontakteApi::Method.new('some_name').tap do |method|
        allow(method).to receive(:full_name).and_return(full_name)
        allow(method).to receive(:token).and_return(token)
      end
    end
    
    before(:each) do
      allow(VkontakteApi::Result).to receive(:process)
    end
    
    it "calls API.call with full name, args and token" do
      expect(VkontakteApi::API).to receive(:call).with(full_name, args, token)
      method.call(args)
    end
    
    it "sends the response to Result.process" do
      response = double("VK response")
      allow(VkontakteApi::API).to receive(:call).and_return(response)
      type = double("Type")
      allow(method).to receive(:type).and_return(type)
      
      expect(VkontakteApi::Result).to receive(:process).with(response, type, nil)
      method.call(args)
    end
  end
  
  describe "#full_name" do
    let(:method) do
      resolver = Hashie::Mash.new(name: 'name_space')
      VkontakteApi::Method.new('name', resolver: resolver)
    end
    
    it "sends each part to #camelize" do
      expect(method.send(:full_name)).to eq('nameSpace.name')
    end
  end
  
  describe "#type" do
    context "with a usual name" do
      it "returns :anything" do
        method = VkontakteApi::Method.new('get')
        expect(method.send(:type)).to eq(:anything)
      end
    end
    
    context "with a predicate name" do
      it "returns :boolean" do
        method = VkontakteApi::Method.new('is_app_user?')
        expect(method.send(:type)).to eq(:boolean)
      end
    end
  end
end
