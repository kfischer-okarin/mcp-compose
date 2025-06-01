# frozen_string_literal: true

require_relative "../test_helper"

module MCPCompose
  describe CLI do
    let(:parse_config) { Minitest::Mock.new }
    let(:build_server) { Minitest::Mock.new }
    let(:cli) { CLI.new(parse_config_function: parse_config, build_server_function: build_server) }

    it "reads the mcp-compose.yml file in the current directory" do
      in_temp_dir do
        mcp_compose_content = <<~YAML
          some: config
        YAML
        File.write("mcp-compose.yml", mcp_compose_content)

        parse_config.expect(:call, :parse_result, [mcp_compose_content])
        server = Minitest::Mock.new
        build_server.expect(:call, server, [:parse_result])
        server.expect(:run, nil)
        cli.run

        value(build_server).must_verify
        value(parse_config).must_verify
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
        parse_config.expect(:call, nil) do |_content|
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
