# frozen_string_literal: true

require_relative "../test_helper"

require_relative "../../lib/mcp_compose/cli"

module MCPCompose
  describe CLI do
    it "reads the mcp-compose.yml file in the current directory" do
      in_temp_dir do
        File.write("mcp-compose.yml", <<~YAML)
          name: test
        YAML
        server_build_config = nil
        cli = CLI.new(build_server_function: ->(config) { server_build_config = config })

        cli.run

        value(server_build_config).must_equal({name: "test"})
      end
    end

    private

    def in_temp_dir(&block)
      Dir.mktmpdir do |dir|
        Dir.chdir(dir, &block)
      end
    end
  end
end
