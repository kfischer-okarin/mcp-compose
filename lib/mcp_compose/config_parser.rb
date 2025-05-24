# frozen_string_literal: true

require "yaml"

require "json_schemer"

module MCPCompose
  class ConfigParser
    SCHEMA_PATH = File.expand_path("../../schema/v1/mcp-compose.schema.json", __dir__)
    class Error < StandardError; end

    def parse(content)
      result = YAML.load(content, symbolize_names: true)

      errors = schema_validator.validate(result).to_a
      if errors.any?
        messages = errors.map { |error| "- #{error['error']}" }
        raise Error, "invalid configuration:\n#{messages.join("\n")}"
      end

      result
    end

    private

    def schema_validator
      @schema_validator ||= JSONSchemer.schema(JSON.load_file(SCHEMA_PATH))
    end
  end
end
