# frozen_string_literal: true

require_relative "../test_helper"

module MCPCompose
  describe CLI do
    let(:parse_config) { Minitest::Mock.new }
    let(:build_server) { Minitest::Mock.new }
    let(:shell_context) { Minitest::Mock.new }
    let(:cli) { CLI.new(parse_config_function: parse_config, build_server_function: build_server) }

    it "reads the mcp-compose.yml file in the current directory" do
      shell_context.expect(:read_file, :mcp_compose_content, ["mcp-compose.yml"])
      parse_config.expect(:call, :parse_result, [:mcp_compose_content])
      server = Minitest::Mock.new
      build_server.expect(:call, server, [:parse_result])
      server.expect(:run, nil)

      cli.run(shell_context: shell_context)

      value(shell_context).must_verify
      value(build_server).must_verify
      value(parse_config).must_verify
      value(server).must_verify
    end

    it "returns a nice error message if the mcp-compose.yml file is not found" do
      shell_context.expect(:read_file, nil) do
        raise Util::ShellContext::FileNotFoundError
      end

      exception = assert_raises(CLI::Error) do
        cli.run(shell_context: shell_context)
      end

      value(exception.message).must_include("mcp-compose.yml not found")
    end

    it "returns a nice error message if the mcp-compose.yml file is invalid" do
      mcp_compose_config_exists
      parse_config.expect(:call, nil) do |_content|
        raise MCPCompose::ConfigParser::Error, "invalid configuration"
      end

      exception = assert_raises(CLI::Error) do
        cli.run(shell_context: shell_context)
      end

      value(exception.message).must_include("invalid configuration")
    end

    private

    def mcp_compose_config_exists
      shell_context.expect(:read_file, :mcp_compose_content, ["mcp-compose.yml"])
    end
  end
end
