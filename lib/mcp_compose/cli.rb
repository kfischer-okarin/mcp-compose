# frozen_string_literal: true

require "yaml"

module MCPCompose
  # Handles command line arguments and configuration and passes the resulting
  # config to the run_server_function
  class CLI
    def initialize(run_server_function:)
      @run_server_function = run_server_function
    end

    def run
      config = YAML.load_file("mcp-compose.yml", symbolize_names: true)
      @run_server_function.call(config)
    end
  end
end
