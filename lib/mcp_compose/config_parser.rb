# frozen_string_literal: true

require "yaml"

module MCPCompose
  class ConfigParser
    def parse(content)
      YAML.load(content, symbolize_names: true)
    end
  end
end
