# frozen_string_literal: true

require "logger"
require_relative "../test_helper"

module MCPCompose
  describe ClientBuilder do
    let(:fake_io) { FakeJSONRPCIO.new }
    let(:shell_context) {
      process_io = fake_io
      Mock.new do |mock|
        mock.method(:spawn_process).returns(process_io)
      end
    }
    let(:client_builder) { ClientBuilder.new(shell_context: shell_context) }

    it "uses shell_context to spawn process for stdio transport" do
      shell_context.mock.method(:spawn_process).expects_call_with("echo hello")

      config = {
        transport: {
          type: "stdio",
          command: "echo hello"
        }
      }

      client = client_builder.build(config)
      client.connect

      shell_context.mock.assert_expected_calls_received
      value(fake_io.received_messages.size).must_equal 2
      value(fake_io.received_messages[0][:method]).must_equal "initialize"
      value(fake_io.received_messages[1][:method]).must_equal "notifications/initialized"
    end

    it "raises error for unsupported transport type" do
      config = {
        transport: {
          type: "unsupported"
        }
      }

      assert_raises(ArgumentError) do
        client_builder.build(config)
      end
    end

    it "passes logger kwarg to IOClient when provided" do
      log_io = StringIO.new
      logger = Logger.new(log_io)

      config = {
        transport: {
          type: "stdio",
          command: "echo hello"
        }
      }

      client = client_builder.build(config, logger: logger)
      client.connect

      value(log_io.string).must_match(/>>.+initialize/)
      value(log_io.string).must_match(/<<.+result/)
    end

    it "re-raises error for non existing executable" do
      shell_context.mock.method(:spawn_process).raises(
        Util::ShellContext::FileNotFoundError,
        "Executable not found: nonexisting"
      )
      config = {
        transport: {
          type: "stdio",
          command: "nonexisting"
        }
      }

      exception = assert_raises(ClientBuilder::BuildError) do
        client_builder.build(config)
      end
      value(exception.message).must_equal("Executable not found: nonexisting")
    end
  end

  class FakeJSONRPCIO
    attr_reader :received_messages

    def initialize
      @received_messages = []
      @last_request_id = nil
    end

    def puts(message)
      parsed = JSON.parse(message, symbolize_names: true)
      @received_messages << parsed
      @last_request_id = parsed[:id] if parsed[:id]
      nil
    end

    def gets
      {jsonrpc: "2.0", id: @last_request_id, result: {}}.to_json
    end
  end
end
