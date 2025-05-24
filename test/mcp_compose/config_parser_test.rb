# frozen_string_literal: true

require_relative "../test_helper"

require_relative "../../lib/mcp_compose/config_parser"

module MCPCompose
  describe ConfigParser do
    it "parses a valid configuration" do
      content = <<~YAML
        name: test
      YAML

      result = ConfigParser.new.parse(content)

      value(result).must_equal({name: "test"})
    end
  end
end
