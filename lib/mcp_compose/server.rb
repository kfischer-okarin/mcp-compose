# frozen_string_literal: true

require "mcp"
require "mcp/transports/stdio"

module MCPCompose
  class Server
    def initialize(config:, client_builder:)
      @config = config
      @client_builder = client_builder
      @wrapped_server = MCP::Server.new(name: config[:name])
      @clients = build_clients
    end

    def handle_request(request)
      @wrapped_server.handle(request)
    end

    def run
      MCP::Transports::StdioTransport.new(@wrapped_server).open
    end

    private

    def build_clients
      return {} unless @config[:servers]

      @config[:servers].transform_values { |server_config|
        @client_builder.build(server_config)
      }
    end
  end
end
