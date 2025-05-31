# frozen_string_literal: true

require "socket"
require "stringio"

require_relative "../test_helper"

require_relative "../../lib/mcp_compose/io_client"

module MCPCompose
  describe IOClient do
    let(:connected_io_pair) { Socket.pair(:UNIX, :STREAM, 0) }
    let(:client_side_io) { connected_io_pair[0] }
    let(:server_side_io) { connected_io_pair[1] }

    it "sends a initialization request and notification to the server when connecting" do
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

    it "logs all sent and received data when log_io is provided" do
      log_io = StringIO.new
      client = IOClient.new(client_side_io, log_io: log_io)

      connect_thread = Thread.new do
        client.connect
      end

      server_side_io.gets
      server_side_io.puts('"some response"')
      server_side_io.gets
      connect_thread.join

      log_content_lines = log_io.string.split("\n")
      value(log_content_lines[0]).must_include ">> {\"jsonrpc\":\"2.0\",\"method\":\"initialize\",\"params\":"
      value(log_content_lines[1]).must_equal "<< \"some response\""
      value(log_content_lines[2]).must_equal ">> {\"jsonrpc\":\"2.0\",\"method\":\"notifications/initialized\"}"
    end
  end
end
