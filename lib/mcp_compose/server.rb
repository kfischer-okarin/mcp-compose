# frozen_string_literal: true

require "mcp"
require "mcp/transports/stdio"

module MCPCompose
  # @param config [Hash] the configuration for the server
  # @param client_builder [ClientBuilder] the client builder to use for creating clients
  # @param logger [Logger] optional Logger instance for logging
  class Server
    def initialize(config:, client_builder:, logger: nil)
      @config = config
      @client_builder = client_builder
      @logger = logger
      @clients = initialize_clients
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

    def initialize_clients
      return {} unless @config[:servers]

      result = {}
      lock = Thread::Mutex.new

      for_each_in_parallel(@config[:servers].keys) do |server_name|
        server_config = @config[:servers][server_name]

        build_args = {}
        if @logger
          # Clone the logger and append the server name to the progname
          client_logger = @logger.dup
          client_logger.progname = "#{@logger.progname}[#{server_name}]"
          build_args[:logger] = client_logger
        end

        client = @client_builder.build(server_config, **build_args)
        client.connect

        lock.synchronize do
          result[server_name] = client
        end
      end

      result
    end

    def setup_tools_list_handler
      @wrapped_server.tools_list_handler do
        @clients.flat_map { |server_name, client|
          client.list_tools
        }
      end
    end

    def for_each_in_parallel(values, &block)
      threads = values.map { |value|
        Thread.new { block.call(value) }
      }
      threads.each(&:join)
    end
  end
end
