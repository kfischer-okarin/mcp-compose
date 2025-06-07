# frozen_string_literal: true

require_relative "../test_helper"

module MCPCompose
  describe Server do
    let(:client_builder) { Minitest::Mock.new }

    specify "specifying the server name" do
      server = build_server(with_config_containing: {
        name: "test"
      })

      initialize_response = server.handle_request initialize_request

      value(initialize_response[:result][:serverInfo][:name]).must_equal "test"
    end

    specify "creates a client for each server in configuration" do
      mock_client1 = Minitest::Mock.new
      mock_client2 = Minitest::Mock.new

      server_config1 = {transport: {type: "stdio", command: "server1"}}
      server_config2 = {transport: {type: "stdio", command: "server2"}}

      client_builder.expect :build, mock_client1, [server_config1]
      client_builder.expect :build, mock_client2, [server_config2]

      build_server(with_config_containing: {
        name: "test",
        servers: {
          server1: server_config1,
          server2: server_config2
        }
      })

      client_builder.verify
    end

    private

    def build_server(with_config_containing: {})
      config = a_valid_config.merge(with_config_containing)
      MCPCompose::Server.new(config: config, client_builder: client_builder)
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
