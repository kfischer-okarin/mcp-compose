# frozen_string_literal: true

require_relative "../test_helper"

module MCPCompose
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

  describe ClientBuilder do
    let(:shell_context) { Minitest::Mock.new }
    let(:client_builder) { ClientBuilder.new(shell_context: shell_context) }

    it "uses shell_context to spawn process for stdio transport" do
      fake_io = FakeJSONRPCIO.new
      shell_context.expect(:spawn_process, fake_io, ["echo hello"])

      config = {
        transport: {
          type: "stdio",
          command: "echo hello"
        }
      }

      client = client_builder.build(config)
      client.connect

      shell_context.verify

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
  end
end
