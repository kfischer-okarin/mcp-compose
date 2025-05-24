# frozen_string_literal: true

require "yaml"

module MCPCompose
  # Handles command line arguments and configuration and passes the resulting
  # config to the build_server_function
  class CLI
    def initialize(build_server_function:)
      @build_server_function = build_server_function
    end

    def run
      config = YAML.load_file("mcp-compose.yml", symbolize_names: true)
      @build_server_function.call(config)
    end
  end
end
