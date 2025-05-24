# frozen_string_literal: true

require_relative "config_parser"

module MCPCompose
  # Handles command line arguments and configuration and passes the resulting
  # config to the run_server_function
  class CLI
    class Error < StandardError; end

    def initialize(run_server_function:)
      @run_server_function = run_server_function
    end

    def run
      config = ConfigParser.new.parse(File.read("mcp-compose.yml"))
      @run_server_function.call(config)
    rescue Errno::ENOENT
      raise Error, "mcp-compose.yml not found"
    end
  end
end
