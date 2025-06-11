# frozen_string_literal: true

require "logger"
require_relative "../test_helper"

module MCPCompose
  describe Server do
    let(:client_builder) {
      mock_client = build_mock_client
      Mock.new do
        method(:build).returns(mock_client)
      end
    }

    specify "specifying the server name" do
      server = build_server(with_config_containing: {
        name: "test"
      })

      initialize_response = server.handle_request initialize_request

      value(initialize_response[:result][:serverInfo][:name]).must_equal "test"
    end

    specify "creates a client for each server in configuration" do
      server_config1 = a_valid_server_config
      server_config2 = a_valid_server_config
      client_builder.mock.method(:build).expects_call_with(server_config1)
      client_builder.mock.method(:build).expects_call_with(server_config2)

      build_server(with_config_containing: {
        servers: {
          server1: server_config1,
          server2: server_config2
        }
      })

      client_builder.mock.assert_expected_calls_received
    end

    specify "connects to all clients during initialization" do
      server_config1 = a_valid_server_config
      server_config2 = a_valid_server_config
      mock_client1 = build_mock_client
      mock_client2 = build_mock_client
      client_builder.mock.method(:build).expects_call_with(server_config1).returns(mock_client1)
      client_builder.mock.method(:build).expects_call_with(server_config2).returns(mock_client2)
      mock_client1.mock.method(:connect).expects_call
      mock_client2.mock.method(:connect).expects_call

      build_server(with_config_containing: {
        servers: {
          server1: server_config1,
          server2: server_config2
        }
      })

      mock_client1.mock.assert_expected_calls_received
      mock_client2.mock.assert_expected_calls_received
    end

    specify "lists tools from all clients" do
      server_config1 = a_valid_server_config
      server_config2 = a_valid_server_config
      mock_client1 = build_mock_client
      mock_client2 = build_mock_client
      client_builder.mock.method(:build).expects_call_with(server_config1).returns(mock_client1)
      client_builder.mock.method(:build).expects_call_with(server_config2).returns(mock_client2)
      mock_client1.mock.method(:list_tools).expects_call.returns([
        {name: "tool1"}
      ])
      mock_client2.mock.method(:list_tools).expects_call.returns([
        {name: "tool2"}
      ])
      server = build_server(with_config_containing: {
        servers: {
          server1: server_config1,
          server2: server_config2
        }
      })

      response = server.handle_request(tools_list_request)

      value(response[:result]).must_equal tools: [
        {name: "tool1"},
        {name: "tool2"}
      ]
      mock_client1.mock.assert_expected_calls_received
      mock_client2.mock.assert_expected_calls_received
    end

    specify "can use logger to log communication of clients" do
      log_output = StringIO.new
      logger = Logger.new(log_output)
      logger.progname = "mcp-compose"

      build_server(
        with_config_containing: {
          servers: {
            server1: a_valid_server_config
          }
        },
        logger: logger
      )

      call = client_builder.mock.calls.find { |call| call[:method] == :build }
      client_logger = call[:kwargs][:logger]

      client_logger.info "test message"
      value(log_output.string).must_include "test message"
      value(log_output.string).must_include "INFO"
      value(log_output.string).must_include "mcp-compose[server1]"
    end

    private

    def build_server(with_config_containing: {}, logger: nil)
      config = a_valid_config.merge(with_config_containing)
      MCPCompose::Server.new(config: config, client_builder: client_builder, logger: logger)
    end

    def build_mock_client
      Mock.new do
        method(:list_tools).returns([])
      end
    end

    def a_valid_config
      {
        name: "test",
        servers: {
          server1: a_valid_server_config,
          server2: a_valid_server_config
        }
      }
    end

    def a_valid_server_config
      {transport: {type: "stdio", command: "server#{rand(1000)}"}}
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

    def tools_list_request
      {
        jsonrpc: "2.0",
        method: "tools/list",
        params: {},
        id: 2
      }
    end
  end
end
