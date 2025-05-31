# frozen_string_literal: true

# This module contains the DSL for acceptance tests.
# Private methods that are not used to express the test cases should be
# defined in AcceptanceTestUtils.
module AcceptanceTestDSL
  def given_a_mcp_server(name, &block)
    ensure_base_dir_is_prepared

    mcp_server_dsl = MCPServerDSL.new(name:, base_dir: @base_dir)
    mcp_server_dsl.instance_eval(&block)
    mcp_server_dsl.build
  end

  def given_a_mcp_compose_file(content)
    ensure_base_dir_is_prepared

    File.write(@base_dir / "mcp-compose.yml", content)
  end

  class MCPServerDSL
    def initialize(name:, base_dir:)
      @name = name
      @base_dir = base_dir
      @tools = []
    end

    def with_tools(*tools)
      @tools += tools
    end

    def build
      executable_path = @base_dir / @name

      tools_code = @tools.map { |tool|
        <<~RUBY
          tools << MCP::Tool.define(
            name: #{tool[:name].inspect},
            description: #{tool[:description].inspect},
            input_schema: #{tool[:inputSchema].inspect}
          ) do |args|
            MCP::Tool::Response.new([{ type: "text", text: "OK" }])
          end
        RUBY
      }.join("\n")

      # For simplicity's sake we will just reuse the current process' bundler environment so we don't have to go
      # through the trouble of making a Gemfile, installing it etc.
      # So this file will just directly require the mcp gem.
      implementation = <<~RUBY
        #!/usr/bin/env ruby

        require "mcp"
        require "mcp/transports/stdio"

        tools = []
        #{tools_code}

        server = MCP::Server.new(name: "#{@name}", tools: tools)
        MCP::Transports::StdioTransport.new(server).open
      RUBY

      File.write(executable_path, implementation)
      File.chmod(0o755, executable_path)
    end
  end
end
