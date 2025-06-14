# frozen_string_literal: true

require "fileutils"

require_relative "../../test_helper"

module MCPCompose
  module Util
    describe ProcessPipe do
      let(:temp_dir) { Dir.mktmpdir }

      after do
        FileUtils.remove_entry temp_dir
      end

      it "exposes the process pid" do
        pipe = ProcessPipe.new("ruby -e 'sleep 0.1'", cwd: temp_dir)

        value(pipe.pid).must_be_kind_of Integer
      end

      it "provides bidirectional gets/puts communication" do
        pipe = ProcessPipe.new("cat", cwd: temp_dir)

        pipe.puts "Hello, TDD!"
        result = pipe.gets

        value(result.chomp).must_equal "Hello, TDD!"
      end

      it "captures stderr separately from stdout" do
        pipe = ProcessPipe.new("ruby -e 'STDERR.puts \"err\"'", cwd: temp_dir)

        err = pipe.stderr.read

        value(err.chomp).must_equal "err"
      end

      it "reports exit_status after the process finishes" do
        pipe = ProcessPipe.new("sh -c 'exit 42'", cwd: temp_dir)

        until pipe.exit_status
          sleep 0.01
        end

        value(pipe.exit_status).must_equal 42
      end

      it "raises ProcessExitedError on read/write after the process has exited" do
        pipe = ProcessPipe.new("echo done", cwd: temp_dir)

        until pipe.exit_status
          sleep 0.01
        end

        assert_raises(ProcessPipe::ProcessExitedError) do
          pipe.puts "cannot write"
        end
        assert_raises(ProcessPipe::ProcessExitedError) do
          pipe.gets
        end
      end
    end
  end
end
