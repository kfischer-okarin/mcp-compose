# frozen_string_literal: true

require "json"

module MCPCompose
  # A simple MCP client communicating via a single bidirectional IO object
  class IOClient
    # @param io [IO] The IO object to use for communication
    # @param log_io [IO] The IO object to use for logging (optional)
    def initialize(io, log_io: nil)
      @io = io
      @log_io = log_io
      @next_id = 1
    end

    # Connects to the server by doing the initial MCP initialize exchange
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
      @log_io.puts(">> #{message}") if @log_io
      @io.puts(message)
    end

    def receive_from_io
      message = @io.gets
      @log_io.puts("<< #{message}") if @log_io
      message
    end
  end
end
