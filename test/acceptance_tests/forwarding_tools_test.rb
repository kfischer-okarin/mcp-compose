# frozen_string_literal: true

require_relative "support/acceptance_test_helper"

feature "Forwarding Tools" do
  scenario "forwards the tools of a server", wip: true do
    given_a_mcp_server("weather-mcp") {
      with_tools Fixtures.weather_tool
    }
    given_a_mcp_server("hello-mcp") {
      with_tools Fixtures.hello_tool
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
