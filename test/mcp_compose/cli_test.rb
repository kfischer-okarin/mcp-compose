# frozen_string_literal: true

require_relative "../test_helper"

require_relative "../../lib/mcp_compose/cli"

module MCPCompose
  describe CLI do
    let(:run_server_function) { Minitest::Mock.new }
    let(:config_parser) { Minitest::Mock.new }
    let(:cli) { CLI.new(run_server_function: run_server_function, config_parser: config_parser) }

    it "reads the mcp-compose.yml file in the current directory" do
      in_temp_dir do
        mcp_compose_content = <<~YAML
          some: config
        YAML
        File.write("mcp-compose.yml", mcp_compose_content)

        config_parser.expect(:parse, :parse_result, [mcp_compose_content])
        run_server_function.expect(:call, nil, [:parse_result])
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

    it "returns a nice error message if the mcp-compose.yml file is invalid" do
      in_temp_dir do
        create_a_mcp_compose_file
        config_parser.expect(:parse, nil) do |_content|
          raise MCPCompose::ConfigParser::Error, "invalid configuration"
        end

        exception = assert_raises(CLI::Error) do
          cli.run
        end
        value(exception.message).must_include("invalid configuration")
      end
    end

    private

    def in_temp_dir(&block)
      Dir.mktmpdir do |dir|
        Dir.chdir(dir, &block)
      end
    end

    def create_a_mcp_compose_file
      File.write("mcp-compose.yml", <<~YAML)
        some: config
      YAML
    end
  end
end
