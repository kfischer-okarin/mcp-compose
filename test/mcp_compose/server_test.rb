# frozen_string_literal: true

require_relative "../test_helper"

module MCPCompose
  describe Server do
    let(:client_builder) { Mock.new }

    specify "specifying the server name" do
      server = build_server(with_config_containing: {
        name: "test"
      })

      initialize_response = server.handle_request initialize_request

      value(initialize_response[:result][:serverInfo][:name]).must_equal "test"
    end

    specify "creates a client for each server in configuration" do
      server_config1 = {transport: {type: "stdio", command: "server1"}}
      server_config2 = {transport: {type: "stdio", command: "server2"}}
      client_builder.mock.method(:build).expects_call_with(server_config1)
      client_builder.mock.method(:build).expects_call_with(server_config2)

      build_server(with_config_containing: {
        name: "test",
        servers: {
          server1: server_config1,
          server2: server_config2
        }
      })

      client_builder.mock.assert_expected_calls_received
    end

    specify "connects to all clients during initialization" do
      server_config1 = {transport: {type: "stdio", command: "server1"}}
      server_config2 = {transport: {type: "stdio", command: "server2"}}
      mock_client1 = Mock.new
      mock_client2 = Mock.new
      client_builder.mock.method(:build).expects_call_with(server_config1).returns(mock_client1)
      client_builder.mock.method(:build).expects_call_with(server_config2).returns(mock_client2)
      mock_client1.mock.method(:connect).expects_call
      mock_client2.mock.method(:connect).expects_call

      build_server(with_config_containing: {
        name: "test",
        servers: {
          server1: server_config1,
          server2: server_config2
        }
      })

      mock_client1.mock.assert_expected_calls_received
      mock_client2.mock.assert_expected_calls_received
    end

    specify "can use log_io to log communication of clients" do
      log_output = StringIO.new
      server_config = {transport: {type: "stdio", command: "test-server"}}

      build_server(
        with_config_containing: {
          name: "test",
          servers: {
            server1: server_config
          }
        },
        log_io: log_output
      )

      call = client_builder.mock.calls.find { |call| call[:method] == :build }
      client_log_io = call[:kwargs][:log_io]
      client_log_io.puts "test message"
      value(log_output.string).must_include "[server1] test message\n"
    end

    private

    def build_server(with_config_containing: {}, log_io: nil)
      config = a_valid_config.merge(with_config_containing)
      MCPCompose::Server.new(config: config, client_builder: client_builder, log_io: log_io)
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
