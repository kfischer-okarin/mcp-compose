# frozen_string_literal: true

require_relative "../test_helper"

require_relative "../../lib/mcp_compose/server"

module MCPCompose
  describe Server do
    specify "the server has the specified name" do
      server = build_server(with_config_containing: {
        name: "test"
      })

      initialize_response = server.handle_request initialize_request

      value(initialize_response[:result][:serverInfo][:name]).must_equal "test"
    end

    private

    def build_server(with_config_containing: {})
      config = a_valid_config.merge(with_config_containing)
      MCPCompose::Server.new(config: config)
    end

    def a_valid_config
      {name: "test"}
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
