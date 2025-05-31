# frozen_string_literal: true

module MCPCompose
  # Handles command line arguments and configuration and passes the resulting
  # config to the run_server_function
  class CLI
    class Error < StandardError; end

    def initialize(run_server_function:, config_parser:)
      @run_server_function = run_server_function
      @config_parser = config_parser
    end

    def run
      config = @config_parser.parse(File.read("mcp-compose.yml"))
      @run_server_function.call(config)
    rescue Errno::ENOENT
      raise Error, "mcp-compose.yml not found"
    rescue MCPCompose::ConfigParser::Error => e
      raise Error, e.message
    end
  end
end
