# frozen_string_literal: true

require_relative "../test_helper"

require_relative "../../lib/mcp_compose/server_builder"

describe MCPCompose::ServerBuilder do
  let(:client_builder) { Minitest::Mock.new }

  specify "the server has the specified name" do
    config = a_valid_config(with: {name: "test"})

    server = build_server(config: config)

    value(server.name).must_equal "test"
  end

  specify "the server returns the tools of the specified servers" do
    config = a_valid_config(
      with: {
        servers: {
          knowledge_base: {
            stdio: "/path/to/start-my-knowledge-base.sh"
          },
          another_server: {
            stdio: "/path/to/start-another-server.sh"
          }
        }
      }
    )
    knowledge_base_client = Minitest::Mock.new
    knowledge_base_client.expect(:list_tools, [:a, :b])
    client_builder.expect(:build, knowledge_base_client, [{stdio: "/path/to/start-my-knowledge-base.sh"}])
    another_server_client = Minitest::Mock.new
    another_server_client.expect(:list_tools, [:c, :d])
    client_builder.expect(:build, another_server_client, [{stdio: "/path/to/start-another-server.sh"}])

    server = build_server(config: config)

    value(list_server_tools(server)).must_equal [:a, :b, :c, :d]
    value(client_builder).must_verify
  end

  private

  def build_server(config:)
    MCPCompose::ServerBuilder.new(config: config, client_builder: client_builder).build
  end

  def a_valid_config(with: {})
    {name: "test"}.merge(with)
  end

  def list_server_tools(server)
    response = server.handle({jsonrpc: "2.0", method: "tools/list", id: 1})
    response[:result][:tools]
  end
end
