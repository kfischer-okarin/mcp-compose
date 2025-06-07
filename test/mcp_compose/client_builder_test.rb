# frozen_string_literal: true

require_relative "../test_helper"

module MCPCompose
  describe ClientBuilder do
    let(:shell_context) { Minitest::Mock.new }
    let(:client_builder) { ClientBuilder.new(shell_context: shell_context) }

    it "uses shell_context to spawn process for stdio transport" do
      mock_io = Minitest::Mock.new
      shell_context.expect(:spawn_process, mock_io, ["echo hello"])

      # Expect the connect method to send the right JSON-RPC messages
      expected_init_request = {
        jsonrpc: "2.0",
        method: "initialize",
        params: {
          protocolVersion: "2025-03-26",
          capabilities: {},
          clientInfo: {
            name: "MCP Compose",
            version: "1.0.0"
          }
        },
        id: 1
      }
      mock_io.expect(:puts, nil, [expected_init_request.to_json])
      mock_io.expect(:gets, '{"jsonrpc":"2.0","id":1,"result":{}}')

      expected_init_notification = {
        jsonrpc: "2.0",
        method: "notifications/initialized"
      }
      mock_io.expect(:puts, nil, [expected_init_notification.to_json])

      config = {
        transport: {
          type: "stdio",
          command: "echo hello"
        }
      }

      client = client_builder.build(config)
      client.connect

      shell_context.verify
      mock_io.verify
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
