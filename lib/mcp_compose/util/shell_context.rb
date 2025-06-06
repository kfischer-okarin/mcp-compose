# frozen_string_literal: true

require "pathname"

module MCPCompose
  module Util
    # This class provides an interface to interact with the shell environment
    class ShellContext
      class FileNotFoundError < StandardError; end

      # @return [Pathname] the current working directory
      attr_reader :cwd

      def initialize(cwd:)
        @cwd = Pathname.new(cwd)
      end

      # @param path [String] the relative path to the file
      # @return [String] the contents of the file
      # @raise [FileNotFoundError] if the file does not exist
      def read_file(path)
        File.read(@cwd / path)
      rescue Errno::ENOENT
        raise FileNotFoundError
      end

      # @param command [String] the command to spawn
      # @return [IO] a bidirectional IO object
      def spawn_process(command)
        IO.popen(command, "r+", chdir: @cwd.to_s)
      end
    end
  end
end
