# frozen_string_literal: true

require_relative "../test_helper"

require_relative "../../lib/mcp_compose/server_builder"

describe MCPCompose::ServerBuilder do
  specify "the server has the specified name" do
    config = a_valid_config(with: {name: "test"})
    builder = MCPCompose::ServerBuilder.new(config: config)

    server = builder.build

    value(server.name).must_equal "test"
  end

  private

  def a_valid_config(with: {})
    {}.merge(with)
  end
end
