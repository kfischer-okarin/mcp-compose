# frozen_string_literal: true

require "mcp"
require "mcp/transports/stdio"

require_relative "util/prefixed_io"

module MCPCompose
  class Server
    def initialize(config:, client_builder:, log_io: nil)
      @config = config
      @client_builder = client_builder
      @log_io = log_io
      @clients = build_clients
      connect_clients
      @wrapped_server = MCP::Server.new(name: config[:name])
      setup_tools_list_handler
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

      @config[:servers].map { |server_name, server_config|
        build_args = {}
        build_args[:log_io] = Util::PrefixedIO.new(@log_io, "[#{server_name}] ") if @log_io
        [server_name, @client_builder.build(server_config, **build_args)]
      }.to_h
    end

    def connect_clients
      threads = @clients.values.map { |client|
        Thread.new { client.connect }
      }
      threads.each(&:join)
    end

    def setup_tools_list_handler
      @wrapped_server.tools_list_handler do
        @clients.flat_map { |server_name, client|
          client.list_tools
        }
      end
    end
  end
end
