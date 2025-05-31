# frozen_string_literal: true

require_relative "../test_helper"

module MCPCompose
  describe CLI do
    let(:server) { Minitest::Mock.new }
    let(:server_builder) { Minitest::Mock.new }
    let(:config_parser) { Minitest::Mock.new }
    let(:cli) { CLI.new(server_builder: server_builder, config_parser: config_parser) }

    it "reads the mcp-compose.yml file in the current directory" do
      in_temp_dir do
        mcp_compose_content = <<~YAML
          some: config
        YAML
        File.write("mcp-compose.yml", mcp_compose_content)

        config_parser.expect(:parse, :parse_result, [mcp_compose_content])
        server_builder.expect(:build, server, [:parse_result])
        server.expect(:run, nil)
        cli.run

        value(server_builder).must_verify
        value(server).must_verify
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
