# frozen_string_literal: true

require "mcp"
require "mcp/transports/stdio"

require_relative "util/prefixed_io"

module MCPCompose
  # @param config [Hash] the configuration for the server
  # @param client_builder [ClientBuilder] the client builder to use for creating clients
  # @param logger [Logger] optional Logger instance for logging
  class Server
    def initialize(config:, client_builder:, logger: nil)
      @config = config
      @client_builder = client_builder
      @logger = logger
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
        if @logger
          # Clone the logger and append the server name to the progname
          client_logger = @logger.dup
          client_logger.progname = "#{@logger.progname}[#{server_name}]"
          build_args[:logger] = client_logger
        end
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
