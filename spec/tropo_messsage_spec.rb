require 'spec_helper'

describe Tropo::Message do
  let(:tropo_message) { Tropo::Message.new }
  describe "#request_xml" do
    it "should escape all parameters" do
      tropo_message.text = "<hello/>+$#%"
      tropo_message.request_xml.should include("%3Chello%2F%3E%2B%24%23%25")
    end
  end
end

