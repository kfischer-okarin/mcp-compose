# frozen_string_literal: true

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
      args << "--log-server-communication" if ENV["ACCEPTANCE_TEST_LOGS"]

      stream = IO.popen(args, "r+", chdir: @base_dir)

      log_io = ENV["ACCEPTANCE_TEST_LOGS"] ? $stderr : nil
      @client = MCPCompose::IOClient.new(stream, log_io: log_io)
      @client.connect
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
