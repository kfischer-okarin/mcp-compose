# frozen_string_literal: true

require_relative "io_client"

module MCPCompose
  # Builds a MCP client based on the given configuration
  #
  # Used by the Server class to create clients for each server in the config
  #
  # @param shell_context [Util::ShellContext] the shell context to use for
  #   spawning processes
  class ClientBuilder
    def initialize(shell_context:)
      @shell_context = shell_context
    end

    # @param config [Hash] the configuration for the client
    # @param log_io [IO] optional IO object for logging
    # @return the client
    def build(config, log_io: nil)
      transport = config[:transport]

      case transport[:type]
      when "stdio"
        io = @shell_context.spawn_process(transport[:command])
        IOClient.new(io, log_io: log_io)
      else
        raise ArgumentError, "Unsupported transport type: #{transport[:type]}"
      end
    end
  end
end
