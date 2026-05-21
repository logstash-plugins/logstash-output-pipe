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

  describe "command resolution" do
    let(:pipe)    { double("pipe") }
    let(:payload) { "test_message; id > /tmp/INJECTED; #" }

    before(:each) do
      allow(PipeWrapper).to receive(:new).and_return(pipe)
      allow(pipe).to receive(:puts)
      subject.register
    end

    shared_examples "resolves command" do
      it "passes the resolved command to PipeWrapper" do
        expect(PipeWrapper).to receive(:new).with(expected_command, anything).and_return(pipe)
        subject.receive(event)
      end
    end

    context "string command coerced to array" do
      subject { LogStash::Outputs::Pipe.new("command" => "logger -t audit %{message}") }
      let(:event)            { LogStash::Event.new("message" => payload) }
      let(:expected_command) { ["logger -t audit #{payload}"] }

      include_examples "resolves command"
    end

    context "array command" do
      context "each element resolved independently" do
        subject { LogStash::Outputs::Pipe.new("command" => ["logger", "-t", "%{tag}", "--", "%{message}"]) }
        let(:event)            { LogStash::Event.new("tag" => "audit", "message" => "hello") }
        let(:expected_command) { ["logger", "-t", "audit", "--", "hello"] }

        include_examples "resolves command"
      end

      context "single-element array" do
        subject { LogStash::Outputs::Pipe.new("command" => ["logger -t audit %{message}"]) }
        let(:event)            { LogStash::Event.new("message" => payload) }
        let(:expected_command) { ["logger -t audit #{payload}"] }

        include_examples "resolves command"
      end
    end
  end

  describe "validation" do
    it "raises ConfigurationError when command is an empty array" do
      plugin = LogStash::Outputs::Pipe.new("command" => [])
      expect { plugin.register }.to raise_error(LogStash::ConfigurationError)
    end
  end
end
