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

  private

  def build_server(config:)
    MCPCompose::ServerBuilder.new(config: config, client_builder: client_builder).build
  end

  def a_valid_config(with: {})
    {}.merge(with)
  end
end
