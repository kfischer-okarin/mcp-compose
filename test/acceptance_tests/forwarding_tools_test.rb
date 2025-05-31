# typed: true

require_relative "support/acceptance_test_helper"

feature "Forwarding Tools" do
  let(:weather_tool) {
    {
      name: "weather",
      description: "Get the weather",
      inputSchema: {
        type: "object",
        properties: {
          location: {
            type: "string",
            description: "The location to get the weather for"
          }
        }
      }
    }
  }
  let(:hello_tool) {
    {
      name: "hello",
      description: "Say hello",
      inputSchema: {
        type: "object",
        properties: {}
      }
    }
  }

  scenario "forwards the tools of a server" do
    given_a_mcp_server("weather-mcp") {
      with_tools weather_tool
    }
    given_a_mcp_server("hello-mcp") {
      with_tools hello_tool
    }
    given_a_mcp_compose_file <<~YAML
      name: My Tools
      servers:
        weather-mcp:
          transport:
            type: stdio
            command: ./weather-mcp
        hello-mcp:
          transport:
            type: stdio
            command: ./hello-mcp
    YAML

    list_tools_result = list_tools

    value(list_tools_result.length).must_equal(2)
    value(list_tools_result).must_include(weather_tool)
    value(list_tools_result).must_include(hello_tool)
  end
end
