# frozen_string_literal: true

require_relative "../test_helper"

require_relative "../../lib/mcp_compose/config_parser"

module MCPCompose
  describe ConfigParser do
    it "parses a valid configuration (examples/mcp-compose.yml)" do
      example_config_content = File.read(File.expand_path("../../examples/mcp-compose.yml", __dir__))

      result = ConfigParser.new.parse(example_config_content)

      expected = {name: "My Tools"}
      value(result).must_equal(expected)
    end

    it "shows an explicit error if the configuration is not valid YAML" do
      content = <<~YAML
        name: test
        notyamlanymore
      YAML

      exception = assert_raises(ConfigParser::Error) do
        ConfigParser.new.parse(content)
      end
      value(exception.message).must_include("invalid YAML")
    end

    it "shows an explicit error message if the configuration is invalid" do
      content = <<~YAML
        name:
          invalid_child: invalid_value
      YAML

      exception = assert_raises(ConfigParser::Error) do
        ConfigParser.new.parse(content)
      end
      value(exception.message).must_include("value at `/name` is not a string")
      value(exception.message).wont_include("$schema", "It should not show the whole error hash")
    end
  end
end
