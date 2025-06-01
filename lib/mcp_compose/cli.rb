# frozen_string_literal: true

module MCPCompose
  # This class is a humble object implementing the command line interface for
  # mcp-compose.
  #
  # @param build_server_function [Proc]
  #   a function that takes a configuration hash and returns a Server instance
  class CLI
    class Error < StandardError; end

    def initialize(build_server_function:, config_parser:)
      @build_server_function = build_server_function
      @config_parser = config_parser
    end

    def run
      config = @config_parser.parse(File.read("mcp-compose.yml"))
      server = @build_server_function.call(config)
      server.run
    rescue Errno::ENOENT
      raise Error, "mcp-compose.yml not found"
    rescue MCPCompose::ConfigParser::Error => e
      raise Error, e.message
    end
  end
end
