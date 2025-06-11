# frozen_string_literal: true

require "logger"

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
      log_level = parse_log_level(args)

      config_content = shell_context.read_file("mcp-compose.yml")
      config = @parse_config_function.call(config_content)

      logger = Logger.new($stderr)
      logger.progname = "mcp-compose"
      logger.level = log_level

      server = @build_server_function.call(config, logger: logger)
      server.run
    rescue Util::ShellContext::FileNotFoundError
      raise Error, "mcp-compose.yml not found"
    rescue MCPCompose::ConfigParser::Error => e
      raise Error, e.message
    end

    private

    def parse_log_level(args)
      log_level_arg = args.find { |arg| arg.start_with?("--log-level=") }

      return Logger::INFO unless log_level_arg

      level_string = log_level_arg.split("=", 2).last.downcase

      case level_string
      when "debug" then Logger::DEBUG
      when "info" then Logger::INFO
      when "warn" then Logger::WARN
      when "error" then Logger::ERROR
      else
        raise Error, "Invalid log level: #{level_string}"
      end
    end
  end
end
