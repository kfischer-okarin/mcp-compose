# frozen_string_literal: true

require "socket"

require_relative "../test_helper"

require_relative "../../lib/mcp_compose/io_client"

module MCPCompose
  describe IOClient do
    it "sends a initialization request and notification to the server when connecting" do
      server_side_io, client_side_io = Socket.pair(:UNIX, :STREAM, 0)
      client = IOClient.new(client_side_io)

      connect_thread = Thread.new do
        client.connect
      end

      first_message = JSON.parse(server_side_io.gets, symbolize_names: true)
      value(first_message.except(:id)).must_equal({
        jsonrpc: "2.0",
        method: "initialize",
        params: {
          protocolVersion: "2025-03-26",
          capabilities: {},
          clientInfo: {
            name: "MCP Compose",
            version: "1.0.0"
          }
        }
      })
      value(connect_thread).must_be :alive?

      response = {
        jsonrpc: "2.0",
        id: first_message[:id],
        result: {
          protocolVersion: "2025-03-26",
          capabilities: {tools: {}},
          serverInfo: {
            name: "test",
            version: "1.0.0"
          }
        }
      }
      server_side_io.puts(response.to_json)
      value(connect_thread).must_be :alive?

      second_message = JSON.parse(server_side_io.gets, symbolize_names: true)
      value(second_message).must_equal({
        jsonrpc: "2.0",
        method: "notifications/initialized"
      })
      value(connect_thread).wont_be :alive?
    end
  end
end
