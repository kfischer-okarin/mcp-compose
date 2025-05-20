# frozen_string_literal: true

require "model_context_protocol"

module MCPCompose
  class ServerBuilder
    def initialize(config:, client_builder:)
      @config = config
      @client_builder = client_builder
    end

    def build
      clients = {}
      (@config[:servers] || {}).each do |name, config|
        clients[name] = @client_builder.build(config)
      end

      server = ModelContextProtocol::Server.new(name: @config[:name])
      server.tools_list_handler do |request|
        clients.values.map(&:list_tools).flatten
      end
      server
    end
  end
end
