# frozen_string_literal: true

require_relative "../test_helper"

require_relative "../../lib/mcp_compose/cli"

module MCPCompose
  describe CLI do
    let(:run_server_function) { Minitest::Mock.new }
    let(:cli) { CLI.new(run_server_function: run_server_function) }

    it "reads the mcp-compose.yml file in the current directory" do
      in_temp_dir do
        File.write("mcp-compose.yml", <<~YAML)
          name: test
        YAML

        run_server_function.expect(:call, nil, [{name: "test"}])
        cli.run

        value(run_server_function).must_verify
      end
    end

    it "returns a nice error message if the mcp-compose.yml file is not found" do
      in_temp_dir do
        exception = assert_raises(CLI::Error) do
          cli.run
        end
        value(exception.message).must_include("mcp-compose.yml not found")
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
