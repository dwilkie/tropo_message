require 'spec_helper'

describe Tropo::Message do
  let(:tropo_message) { Tropo::Message.new }
  let(:tropo_session) {
    {
      "session" => {
        "id"=>"703c4f12c46dd3a7ae07c95ee68f8b79",
        "account_id"=>"12345",
        "timestamp"=>Time.now,
        "user_type"=>"NONE",
        "initial_text"=>nil,
        "call_id"=>nil,
        "parameters"=>{
          "token" => "123451234512345123451234512345123451234512345",
          "text"=>"Hi%2C+how+r+u+today+%3A+my+friend+%3Cyour+name",
          "to"=>"612382211234",
          "from" => "661213433198",
          "channel" => "SomeChannel",
          "network" => "SomeNetwork",
          "action" => "SomeAction",
          "timeout" => "SomeTimeout",
          "answer_on_media" => "Phone",
          "headers" => "MyCustomHeaders",
          "recording" => "MyRecording"
        }
      }
    }
  }

  # Interesting methods
  describe "#request_xml" do
    it "should generate xml that includes all the message parameter keys and values" do
      tropo_message.params = {"my_favourite_food" => "pho"}
      tropo_message.request_xml.should include("my_favourite_food")
      tropo_message.request_xml.should include("pho")
    end
    it "should generate xml that includes the session token" do
      tropo_message.token = "23932349191932432"
      tropo_message.request_xml.should include("token")
      tropo_message.request_xml.should include("23932349191932432")
    end
    it "should escape all message parameters" do
      tropo_message.text = "<hello/>+$#%"
      tropo_message.request_xml.should include("%3Chello%2F%3E%2B%24%23%25")
    end
  end

  describe "#parse" do
    it "should set the @tropo_session instance variable" do
      tropo_message.parse(tropo_session)
      tropo_message.tropo_session.should == tropo_session
    end
  end

  describe "#outgoing?" do
    context "setting up a message for sending" do
      it "should be false" do
        tropo_message.should_not be_outgoing
      end
    end
    context "responding to tropo" do
      context "the session has a 'parameters' hash" do
        it "should be true" do
          tropo_message.parse(tropo_session)
          tropo_message.should be_outgoing
        end
      end
      context "the session does not have a 'parameters' hash" do
        before do
          tropo_session["session"].delete("parameters")
        end
        it "should be false" do
          tropo_message.parse(tropo_session)
          tropo_message.should_not be_outgoing
        end
      end
    end
  end

  describe "#response_params" do
    # see also: http://github.com/voxeo/tropo-webapi-ruby
    context "the tropo session parameters include all the required and optional parameters for Tropo::Generator#message" do
      it "should include all the required and optional parameters" do
        tropo_message.parse(tropo_session)
        tropo_message.response_params.should == {
          "to" => "612382211234",
          "channel" => "SomeChannel",
          "network" => "SomeNetwork",
          "from" => "661213433198",
          "timeout" => "SomeTimeout",
          "answer_on_media" => "Phone",
          "headers" => "MyCustomHeaders",
          "recording" => "MyRecording"
        }
      end
    end
    context "the tropo session parameters only includes 'to'" do
      before do
        parameters = tropo_session["session"].delete("parameters")
        tropo_session["session"]["parameters"] = { "to" => parameters["to"] }
      end
      it "should include all the required parameters" do
        tropo_message.parse(tropo_session)
        tropo_message.response_params.should == {
          "to" => "612382211234",
          "channel" => "TEXT",
          "network" => "SMS",
        }
      end
    end
  end

  # Less interesting methods
  # Methods with setters
  describe "#token" do
    context "setting up a message for sending" do
      it "should set the token" do
        tropo_message.token = "my token"
        tropo_message.token.should == "my token"
      end
    end
    context "responding to tropo" do
      it "should return the token from the session parameters" do
        tropo_message.parse(tropo_session)
        tropo_message.token.should == "123451234512345123451234512345123451234512345"
      end
    end
  end

  describe "#to" do
    context "setting up a message for sending" do
      it "should set the receiver" do
        tropo_message.to = "841232312342"
        tropo_message.to.should == "841232312342"
      end
    end
    context "responding to tropo" do
      it "should return the receiver from the session parameters" do
        tropo_message.parse(tropo_session)
        tropo_message.to.should == "612382211234"
      end
    end
  end

  describe "#from" do
    context "setting up a message for sending" do
      it "should set the sender" do
        tropo_message.from = "1331485573"
        tropo_message.from.should == "1331485573"
      end
    end
    context "responding to tropo" do
      it "should return the sender from the session parameters" do
        tropo_message.parse(tropo_session)
        tropo_message.from.should == "661213433198"
      end
    end
  end

  describe "#text" do
    context "setting up a message for sending" do
      it "should set the text" do
        tropo_message.text = "hello johnny (whats happening?)"
        tropo_message.text.should == "hello johnny (whats happening?)"
      end
    end
    context "responding to tropo" do
      it "should return the text from the session parameters" do
        tropo_message.parse(tropo_session)
        tropo_message.text.should == "Hi%2C+how+r+u+today+%3A+my+friend+%3Cyour+name"
      end
    end
  end

  # Methods without setters
  # Methods with default return values
  describe "#channel" do
    context "setting up a message for sending" do
      it "should set the channel" do
        tropo_message.params = {"channel" => "Channel 8"}
        tropo_message.channel.should == "Channel 8"
      end
    end
    context "responding to tropo" do
      context "'channel' is in the session parameters" do
        it "should return the channel from the session parameters" do
          tropo_message.parse(tropo_session)
          tropo_message.channel.should == "SomeChannel"
        end
      end
      context "'channel' is not in the session parameters" do
        before do
          tropo_session["session"]["parameters"].delete("channel")
        end
        it "should return 'TEXT'" do
          tropo_message.parse(tropo_session)
          tropo_message.channel.should == "TEXT"
        end
      end
    end
  end

  describe "#network" do
    context "setting up a message for sending" do
      it "should set the network" do
        tropo_message.params = {"network" => "Network 10"}
        tropo_message.network.should == "Network 10"
      end
    end
    context "responding to tropo" do
      context "'network' is in the session parameters" do
        it "should return the network from the session parameters" do
          tropo_message.parse(tropo_session)
          tropo_message.network.should == "SomeNetwork"
        end
      end
      context "'network' is not in the session parameters" do
        before do
          tropo_session["session"]["parameters"].delete("network")
        end
        it "should return 'SMS'" do
          tropo_message.parse(tropo_session)
          tropo_message.network.should == "SMS"
        end
      end
    end
  end

  # Methods without default return values
  describe "#action" do
    context "setting up a message for sending" do
      it "should set the action" do
        tropo_message.params = {"action" => "my action"}
        tropo_message.action.should == "my action"
      end
    end
    context "responding to tropo" do
      context "'action' is in the session parameters" do
        it "should return the action from the session parameters" do
          tropo_message.parse(tropo_session)
          tropo_message.action.should == "SomeAction"
        end
      end
      context "'action' is not in the session parameters" do
        before do
          tropo_session["session"]["parameters"].delete("action")
        end
        it "should return nil" do
          tropo_message.parse(tropo_session)
          tropo_message.action.should be_nil
        end
      end
    end
  end

  describe "#timeout" do
    context "setting up a message for sending" do
      it "should set the timeout" do
        tropo_message.params = {"timeout" => "5 seconds"}
        tropo_message.timeout.should == "5 seconds"
      end
    end
    context "responding to tropo" do
      context "'timeout' is in the session parameters" do
        it "should return the timeout from the session parameters" do
          tropo_message.parse(tropo_session)
          tropo_message.timeout.should == "SomeTimeout"
        end
      end
      context "'timeout' is not in the session parameters" do
        before do
          tropo_session["session"]["parameters"].delete("timeout")
        end
        it "should return nil" do
          tropo_message.parse(tropo_session)
          tropo_message.timeout.should be_nil
        end
      end
    end
  end

  describe "#answer_on_media" do
    context "setting up a message for sending" do
      it "should set answer_on_media" do
        tropo_message.params = {"answer_on_media" => "yes"}
        tropo_message.answer_on_media.should == "yes"
      end
    end
    context "responding to tropo" do
      context "'answer_on_media' is in the session parameters" do
        it "should return 'answer_on_media' from the session parameters" do
          tropo_message.parse(tropo_session)
          tropo_message.answer_on_media.should == "Phone"
        end
      end
      context "'answer_on_media' is not in the session parameters" do
        before do
          tropo_session["session"]["parameters"].delete("answer_on_media")
        end
        it "should return nil" do
          tropo_message.parse(tropo_session)
          tropo_message.answer_on_media.should be_nil
        end
      end
    end
  end

  describe "#headers" do
    context "setting up a message for sending" do
      it "should set the headers" do
        tropo_message.params = {"headers" => "some custom headers"}
        tropo_message.headers.should == "some custom headers"
      end
    end
    context "responding to tropo" do
      context "'headers' is in the session parameters" do
        it "should return the headers from the session parameters" do
          tropo_message.parse(tropo_session)
          tropo_message.headers.should == "MyCustomHeaders"
        end
      end
      context "'headers' is not in the session parameters" do
        before do
          tropo_session["session"]["parameters"].delete("headers")
        end
        it "should return nil" do
          tropo_message.parse(tropo_session)
          tropo_message.headers.should be_nil
        end
      end
    end
  end

  describe "#recording" do
    context "setting up a message for sending" do
      it "should set the recording" do
        tropo_message.params = {"recording" => "my recording"}
        tropo_message.recording.should == "my recording"
      end
    end
    context "responding to tropo" do
      context "'recording' is in the session parameters" do
        it "should return the recording from the session parameters" do
          tropo_message.parse(tropo_session)
          tropo_message.recording.should == "MyRecording"
        end
      end
      context "'recording' is not in the session parameters" do
        before do
          tropo_session["session"]["parameters"].delete("recording")
        end
        it "should return nil" do
          tropo_message.parse(tropo_session)
          tropo_message.recording.should be_nil
        end
      end
    end
  end
end

