# frozen_string_literal: true

require "json"

module MCPCompose
  # A simple MCP client communicating via a single bidirectional IO object
  class IOClient
    def initialize(io)
      @io = io
      @next_id = 1
    end

    def connect
      send_json_rpc_request(
        method: "initialize",
        params: {
          protocolVersion: "2025-03-26",
          capabilities: {},
          clientInfo: {
            name: "MCP Compose",
            version: "1.0.0"
          }
        }
      )
      send_json_rpc_notification(method: "notifications/initialized")
    end

    private

    def send_json_rpc_request(method:, params: nil)
      request = {
        jsonrpc: "2.0",
        method: method,
        params: params,
        id: @next_id
      }
      @next_id += 1
      send_via_io(request.to_json)
      JSON.parse(receive_from_io, symbolize_names: true)
    end

    def send_json_rpc_notification(method:, params: nil)
      notification = {
        jsonrpc: "2.0",
        method: method,
        params: params
      }.compact
      send_via_io(notification.to_json)
    end

    def send_via_io(message)
      @io.puts(message)
    end

    def receive_from_io
      @io.gets
    end
  end
end
