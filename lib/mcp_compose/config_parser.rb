# frozen_string_literal: true

require "yaml"

require "json_schemer"

module MCPCompose
  # Handles parsing and validation of the mcp-compose.yml file
  class ConfigParser
    SCHEMA_PATH = File.expand_path("../../schema/v1/mcp-compose.schema.json", __dir__)

    class Error < StandardError; end

    # @param cwd [String] the current working directory, used to resolve relative paths in the configuration
    def initialize(cwd:)
      @cwd = cwd
    end

    # Parses and validates the given YAML content as mcp-compose configuration.
    #
    # The resulting configuration will be normalized, i.e. it will explicitly contain the default values for all
    # optional fields.
    #
    # @param content [String] the content of the mcp-compose.yml file
    # @returns [Hash] the parsed, normalized configuration
    # @raises [Error] if the configuration is invalid
    def parse(content)
      begin
        result = YAML.load(content, symbolize_names: true)
      rescue Psych::SyntaxError => e
        raise Error, "invalid configuration: invalid YAML\n#{e.message}"
      end

      errors = schema_validator.validate(result).to_a
      if errors.any?
        messages = errors.map { |error| "- #{error["error"]}" }
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
