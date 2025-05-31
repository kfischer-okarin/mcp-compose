# frozen_string_literal: true

require "mcp"
require "mcp/transports/stdio"

module MCPCompose
  class Server
    def initialize(config:)
      @config = config
      @wrapped_server = MCP::Server.new(name: config[:name])
    end

    def handle_request(request)
      @wrapped_server.handle(request)
    end

    def run
      MCP::Transports::StdioTransport.new(@wrapped_server).open
    end
  end
end
