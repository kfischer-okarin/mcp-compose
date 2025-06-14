# frozen_string_literal: true

require_relative "support/acceptance_test_helper"

feature "Connection Errors" do
  scenario "reports when a server binary cannot be found" do
    given_a_mcp_server("weather-mcp") {
      with_tools Fixtures.weather_tool
    }
    given_a_mcp_compose_file <<~YAML
      name: My Tools
      servers:
        weather-mcp:
          transport:
            type: stdio
            command: ./weather-mcp
        nonexisting-mcp:
          transport:
            type: stdio
            command: ./nonexisting-mcp
    YAML

    value(error_logs_during_connection).must_match(/Failed to start server 'nonexisting-mcp'.+No such file or directory.+\/nonexisting-mcp/)
  end

  scenario "reports when a server process exits with an error" do
    given_a_mcp_server("faulty-mcp") {
      exits_with_error_message "Something went wrong"
    }
    given_a_mcp_compose_file <<~YAML
      name: My Tools
      servers:
        faulty-mcp:
          transport:
            type: stdio
            command: ./faulty-mcp
    YAML

    value(error_logs_during_connection).must_match(/Server 'faulty-mcp' unexpectedly exited with error:.+Something went wrong/)
  end
end
