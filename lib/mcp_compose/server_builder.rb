# frozen_string_literal: true

require "model_context_protocol"

module MCPCompose
  class ServerBuilder
    def initialize(config:, client_builder:)
      @config = config
      @client_builder = client_builder
    end

    def build
      ModelContextProtocol::Server.new(name: @config[:name])
    end
  end
end
