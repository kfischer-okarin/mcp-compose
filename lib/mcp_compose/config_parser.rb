# frozen_string_literal: true

require "yaml"

module MCPCompose
  class ConfigParser
    def initialize(content)
      @content = content
    end

    def parsed_config
      YAML.load(@content, symbolize_names: true)
    end
  end
end
