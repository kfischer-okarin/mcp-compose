# frozen_string_literal: true

module MCPCompose
  class ServerBuilder
    def build(config)
      Server.new(config: config)
    end
  end
end
