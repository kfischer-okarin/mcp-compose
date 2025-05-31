# typed: true

require_relative "support/acceptance_test_helper"

feature "Forwarding Tools" do
  scenario "forwards the tools of a server" do
    given_a_mcp_server("weather-mcp") {
      with_tools Tools.weather
    }
    given_a_mcp_server("hello-mcp") {
      with_tools Tools.hello
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

  module Tools
    module_function

    def weather
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
    end

    def hello
      {
        name: "hello",
        description: "Say hello",
        inputSchema: {
          type: "object",
          properties: {}
        }
      }
    end
  end
end
