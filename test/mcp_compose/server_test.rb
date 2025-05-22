# frozen_string_literal: true

require_relative "../test_helper"

require_relative "../../lib/mcp_compose/server"

module MCPCompose
  describe Server do
    specify "the server has the specified name" do
      config = a_valid_config(with: {name: "test"})
      server = build_server(config: config)

      initialize_response = server.handle_request initialize_request

      value(initialize_response[:result][:serverInfo][:name]).must_equal "test"
    end

    private

    def a_valid_config(with: {})
      {}.merge(with)
    end

    def build_server(config: a_valid_config)
      MCPCompose::Server.new(config: config)
    end

    def initialize_request
      {
        jsonrpc: "2.0",
        method: "initialize",
        params: {
          protocolVersion: "2025-03-26",
          capabilities: {},
          clientInfo: {
            name: "Some Client",
            version: "1.0.0"
          }
        },
        id: 1
      }
    end
  end
end
