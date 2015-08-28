# encoding: utf-8
require_relative "../spec_helper"
require "logstash/plugin"
require "logstash/event"

describe LogStash::Outputs::Pipe do

  let(:format) { "%{message}" }
  let(:cmd)    { "cmd" }

  it "should register without errors" do
    plugin = LogStash::Plugin.lookup("output", "pipe").new({"command" => cmd})
    expect { plugin.register }.to_not raise_error
  end

  describe "#send" do

    subject { LogStash::Outputs::Pipe.new("command" => cmd) }

    let(:properties) { { "message" => "This is a message!"} }
    let(:event)      { LogStash::Event.new(properties) }

    let(:pipe)       { double("pipe") }
    before(:each) do
      allow(PipeWrapper).to receive(:new).and_return(pipe)
      subject.register
    end

    it "sends the generated event to the pipe" do
      expect(pipe).to receive(:puts).with(event.to_json)
      subject.receive(event)
    end

  end
end
