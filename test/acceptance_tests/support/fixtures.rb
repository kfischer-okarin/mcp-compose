# frozen_string_literal: true

module Fixtures
  module_function

  def weather_tool
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

  def hello_tool
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
