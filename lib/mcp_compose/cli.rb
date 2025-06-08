# frozen_string_literal: true

module MCPCompose
  # This class is a humble object implementing the command line interface for
  # mcp-compose.
  #
  # @param parse_config_function [Proc]
  #   a function that takes a YAML string and returns a parsed configuration hash
  # @param build_server_function [Proc]
  #   a function that takes a configuration hash and returns a Server instance
  class CLI
    class Error < StandardError; end

    def initialize(parse_config_function:, build_server_function:)
      @parse_config_function = parse_config_function
      @build_server_function = build_server_function
    end

    def run(shell_context:, args: [])
      log_server_communication = args.include?("--log-server-communication")

      config_content = shell_context.read_file("mcp-compose.yml")
      config = @parse_config_function.call(config_content)

      server = if log_server_communication
        @build_server_function.call(config, log_io: $stderr)
      else
        @build_server_function.call(config)
      end

      server.run
    rescue Util::ShellContext::FileNotFoundError
      raise Error, "mcp-compose.yml not found"
    rescue MCPCompose::ConfigParser::Error => e
      raise Error, e.message
    end
  end
end
