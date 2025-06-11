# frozen_string_literal: true

require "logger"
require_relative "../test_helper"

module MCPCompose
  describe CLI do
    let(:built_server) { Mock.new }
    let(:parse_config) { Mock.new }
    let(:build_server) {
      server = built_server
      Mock.new do |mock|
        mock.method(:call).returns(server)
      end
    }
    let(:build_server_call) {
      build_server.mock.calls.find { |c| c[:method] == :call }
    }
    let(:shell_context) { Mock.new }
    let(:cli) { CLI.new(parse_config_function: parse_config, build_server_function: build_server) }

    it "parses the mcp-compose.yml file in the current directory and uses it to start the server" do
      shell_context.mock.method(:read_file).expects_call_with("mcp-compose.yml").returns(:mcp_compose_content)
      parse_config.mock.method(:call).expects_call_with(:mcp_compose_content).returns(:parse_result)
      build_server.mock.method(:call).expects_call.returns(built_server)
      built_server.mock.method(:run).expects_call

      cli.run(shell_context: shell_context, args: [])

      shell_context.mock.assert_expected_calls_received
      parse_config.mock.assert_expected_calls_received
      build_server.mock.assert_expected_calls_received
      value(build_server_call[:args]).must_equal [:parse_result]
      built_server.mock.assert_expected_calls_received
    end

    it "returns a nice error message if the mcp-compose.yml file is not found" do
      shell_context.mock.method(:read_file).raises(Util::ShellContext::FileNotFoundError)

      exception = assert_raises(CLI::Error) do
        cli.run(shell_context: shell_context, args: [])
      end

      value(exception.message).must_include("mcp-compose.yml not found")
    end

    it "returns a nice error message if the mcp-compose.yml file is invalid" do
      parse_config.mock.method(:call).raises(MCPCompose::ConfigParser::Error, "invalid configuration")

      exception = assert_raises(CLI::Error) do
        cli.run(shell_context: shell_context, args: [])
      end

      value(exception.message).must_include("invalid configuration")
    end

    describe "with --log-level argument" do
      %w[debug info warn error].each do |level|
        it "passes logger with #{level.upcase} level when --log-level=#{level} is present" do
          cli.run(shell_context: shell_context, args: ["--log-level=#{level}"])

          logger_arg = build_server_call[:kwargs][:logger]
          value(logger_arg.level).must_equal Logger.const_get(level.upcase)
        end
      end

      it "raises error for invalid log level" do
        exception = assert_raises(CLI::Error) do
          cli.run(shell_context: shell_context, args: ["--log-level=invalid"])
        end

        value(exception.message).must_include("Invalid log level: invalid")
      end

      it "uses INFO as default log level when no --log-level is specified" do
        cli.run(shell_context: shell_context, args: [])

        value(build_server_call[:kwargs][:logger].level).must_equal Logger::INFO
      end
    end
  end
end
