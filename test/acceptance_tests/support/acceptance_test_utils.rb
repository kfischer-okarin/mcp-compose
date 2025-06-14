# frozen_string_literal: true

require "logger"
require "pathname"

require_relative "../../../lib/mcp_compose/io_client"

# This module contains private utility methods for acceptance tests which are
# not listed among the available DSL methods.
module AcceptanceTestUtils
  class << self
    def local_tmp_dir
      (project_root_dir / "tmp").tap(&:mkpath)
    end

    def project_root_dir
      current = Pathname.new(__dir__)
      current = current.parent until (current / "Gemfile").exist?
      current
    end

    def line_processing_pipe(&block)
      read_pipe, write_pipe = IO.pipe
      Thread.new do
        read_pipe.each_line(&block)
      end
      write_pipe
    end
  end

  private

  def ensure_base_dir_is_prepared
    @base_dir ||= Pathname.new(Dir.mktmpdir("mcp-compose-acceptance-tests"))
  end

  def client
    unless @client
      ensure_base_dir_is_prepared

      mcp_compose_absolute_path = AcceptanceTestUtils.project_root_dir / "exe" / "mcp-compose"
      args = [mcp_compose_absolute_path.to_s]
      # Suppress the server logs by default
      server_log_level = ENV["ACCEPTANCE_TEST_LOGS"] ? "debug" : "warn"
      args << "--log-level=#{server_log_level}"

      @error_logs = +""
      capture_stderr_pipe = AcceptanceTestUtils.line_processing_pipe do |line|
        if line.include?("ERROR --")
          # Logs emitted by the logger
          @error_logs << line
          warn line if ENV["ACCEPTANCE_TEST_LOGS"]
        else
          # Unexpected other errors
          warn line
        end
      end

      stream = IO.popen(args, "r+", chdir: @base_dir, err: capture_stderr_pipe)

      logger = ENV["ACCEPTANCE_TEST_LOGS"] ? Logger.new($stderr) : nil
      @client = MCPCompose::IOClient.new(stream, logger: logger)
      @client.connect
      @error_logs_during_connection = @error_logs.dup
    end

    @client
  end

  def method_missing(name, *args, &block)
    message = <<~MESSAGE
      undefined DSL method `#{name}`

      Available methods:
    MESSAGE
    AcceptanceTestDSL.instance_methods(false).sort.each do |method|
      message << "- #{method}\n"
    end
    skip(message)
  end

  def respond_to_missing?(name, include_private = false)
    # We never throw a NoMethodError because method_missing will always skip the test instead but that doesn't mean
    # that the object is really responding to the method. So we just use the default implementation.
    super
  end
end
