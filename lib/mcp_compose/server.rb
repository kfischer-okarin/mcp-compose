# frozen_string_literal: true

require "model_context_protocol"
require "model_context_protocol/transports/stdio"

module MCPCompose
  class Server
    def initialize(config:)
      @config = config
      @wrapped_server = ModelContextProtocol::Server.new(name: config[:name])
    end

    def handle_request(request)
      @wrapped_server.handle(request)
    end

    def run
      ModelContextProtocol::Transports::StdioTransport.new(@wrapped_server).open
    end
  end
end
