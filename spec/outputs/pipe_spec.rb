# encoding: utf-8
require_relative "../spec_helper"
require "logstash/plugin"
require "logstash/event"

describe "LogStash::Outputs::Pipe" do

  let(:format) { "%{message}" }
  let(:cmd)    { "cmd" }

  it "should register without errors" do
    plugin = LogStash::Plugin.lookup("output", "pipe").new({"command" => cmd})
    expect { plugin.register }.to_not raise_error
  end

end
