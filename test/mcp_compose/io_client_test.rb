# frozen_string_literal: true

require "logger"
require "socket"
require "stringio"

require_relative "../test_helper"

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

      first_message = next_client_message
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
      send_to_client_as_json(response)
      value(connect_thread).must_be :alive?

      second_message = next_client_message
      value(second_message).must_equal({
        jsonrpc: "2.0",
        method: "notifications/initialized"
      })
      value(connect_thread).wont_be :alive?
    end

    it "logs all sent and received data when logger is provided" do
      log_io = StringIO.new
      logger = Logger.new(log_io)
      client = IOClient.new(client_side_io, logger: logger)

      connect_thread = Thread.new do
        client.connect
      end

      next_client_message
      send_to_client_as_json("some response")
      next_client_message
      connect_thread.join

      log_content = log_io.string
      value(log_content).must_include ">> {\"jsonrpc\":\"2.0\",\"method\":\"initialize\",\"params\":"
      value(log_content).must_include "<< \"some response\""
      value(log_content).must_include ">> {\"jsonrpc\":\"2.0\",\"method\":\"notifications/initialized\"}"

      # Assert that messages are logged at INFO level
      log_lines = log_content.split("\n")
      log_lines.each do |line|
        value(line).must_include "INFO" if line.include?(">>") || line.include?("<<")
      end
    end

    it "can retrieve the tools list" do
      client = IOClient.new(client_side_io)

      thread = Thread.new do
        client.list_tools
      end

      message = next_client_message
      value(message.except(:id)).must_equal({
        jsonrpc: "2.0",
        method: "tools/list"
      })

      send_to_client_as_json({
        jsonrpc: "2.0",
        id: message[:id],
        result: {
          tools: ["one", "two", "three"]
        }
      })

      tools = thread.value
      value(tools).must_equal(["one", "two", "three"])
    end

    private

    def next_client_message
      JSON.parse(server_side_io.gets, symbolize_names: true)
    end

    def send_to_client_as_json(value)
      server_side_io.puts(value.to_json)
    end
  end
end
