# frozen_string_literal: true

require "open3"

module MCPCompose
  module Util
    # Simple IO like object for bidirectional communication with a process
    #
    # It throws ProcessExitedError if read or write is called after the process
    # has exited
    #
    # @param command [String] the command to run
    # @param cwd [String] the current working directory
    class ProcessPipe
      class ProcessExitedError < StandardError; end

      # @return [Integer] the process ID
      attr_reader :pid

      # @return [Integer] the exit status of the process, nil if the process is still running
      attr_reader :exit_status

      def initialize(command, cwd:)
        @command = command
        @cwd = cwd
        @exit_status = nil
        @stdin = nil
        @stdout = nil
        @stderr_reader, @stderr_writer = IO.pipe

        start_process
      end

      def puts(message)
        @stdin.puts(message)
        @stdin.flush
      rescue Errno::EPIPE
        raise ProcessExitedError, "Process has exited"
      end

      def gets
        result = @stdout.gets
        raise ProcessExitedError, "Process has exited" unless result

        result
      end

      # @return [IO] the stderr stream
      def stderr
        @stderr_reader
      end

      private

      def start_process
        @stdin, @stdout, stderr_writer, @wait_thread = Open3.popen3(@command, chdir: @cwd)
        @pid = @wait_thread.pid

        # Copy stderr to our pipe
        Thread.new do
          IO.copy_stream(stderr_writer, @stderr_writer)
        ensure
          @stderr_writer.close
          stderr_writer.close
        end

        # Monitor process exit
        Thread.new do
          @wait_thread.join
          @exit_status = @wait_thread.value.exitstatus
        end
      end
    end
  end
end
