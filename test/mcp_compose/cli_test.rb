# frozen_string_literal: true

require_relative "../test_helper"

module MCPCompose
  describe CLI do
    let(:parse_config) { Mock.new }
    let(:build_server) { Mock.new }
    let(:shell_context) { Mock.new }
    let(:cli) { CLI.new(parse_config_function: parse_config, build_server_function: build_server) }

    it "reads the mcp-compose.yml file in the current directory" do
      shell_context.mock.method(:read_file).expects_call_with("mcp-compose.yml").returns(:mcp_compose_content)
      parse_config.mock.method(:call).expects_call_with(:mcp_compose_content).returns(:parse_result)
      server = Mock.new
      build_server.mock.method(:call).expects_call_with(:parse_result).returns(server)
      server.mock.method(:run).expects_call

      cli.run(shell_context: shell_context)

      shell_context.mock.assert_expected_calls_received
      parse_config.mock.assert_expected_calls_received
      build_server.mock.assert_expected_calls_received
      server.mock.assert_expected_calls_received
    end

    it "returns a nice error message if the mcp-compose.yml file is not found" do
      shell_context.mock.method(:read_file).raises(Util::ShellContext::FileNotFoundError)

      exception = assert_raises(CLI::Error) do
        cli.run(shell_context: shell_context)
      end

      value(exception.message).must_include("mcp-compose.yml not found")
    end

    it "returns a nice error message if the mcp-compose.yml file is invalid" do
      parse_config.mock.method(:call).raises(MCPCompose::ConfigParser::Error, "invalid configuration")

      exception = assert_raises(CLI::Error) do
        cli.run(shell_context: shell_context)
      end

      value(exception.message).must_include("invalid configuration")
    end
  end
end
