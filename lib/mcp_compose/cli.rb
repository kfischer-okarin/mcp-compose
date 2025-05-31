# frozen_string_literal: true

module MCPCompose
  # Handles command line arguments and configuration and passes the resulting
  # config to the run_server_function
  class CLI
    class Error < StandardError; end

    def initialize(server_builder:, config_parser:)
      @server_builder = server_builder
      @config_parser = config_parser
    end

    def run
      config = @config_parser.parse(File.read("mcp-compose.yml"))
      server = @server_builder.build(config)
      server.run
    rescue Errno::ENOENT
      raise Error, "mcp-compose.yml not found"
    rescue MCPCompose::ConfigParser::Error => e
      raise Error, e.message
    end
  end
end
