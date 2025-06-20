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

  def list_tools
    client.list_tools
  end

  def error_logs_during_connection
    client # Ensure the client is initialized
    @error_logs_during_connection
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

    def exits_with_error_message(message)
      @error_message = message
    end

    def build
      executable_path = @base_dir / @name

      generator = ImplementationGenerator.new(name: @name, tools: @tools, error_message: @error_message)
      implementation = generator.generate

      File.write(executable_path, implementation)
      File.chmod(0o755, executable_path)
    end

    class ImplementationGenerator
      def initialize(name:, tools:, error_message:)
        @name = name
        @tools = tools
        @error_message = error_message
      end

      def generate
        if @error_message
          return <<~RUBY
            #!/usr/bin/env ruby

            warn "#{@error_message}"
            exit 1
          RUBY
        end

        <<~RUBY
          #!/usr/bin/env ruby

          require "mcp"
          require "mcp/transports/stdio"

          tools = []
          #{generate_tools_code}

          server = MCP::Server.new(name: "#{@name}", tools: tools)
          MCP::Transports::StdioTransport.new(server).open
        RUBY
      end

      private

      def generate_tools_code
        @tools.map { |tool|
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
      end
    end
  end
end
