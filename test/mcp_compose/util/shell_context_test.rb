# frozen_string_literal: true

require "fileutils"

require_relative "../../test_helper"

module MCPCompose
  module Util
    describe ShellContext do
      let(:temp_dir) { Dir.mktmpdir }
      let(:shell_context) { ShellContext.new(cwd: temp_dir) }

      after do
        FileUtils.remove_entry temp_dir
      end

      it "can return the current working directory" do
        value(shell_context.cwd.to_s).must_equal(temp_dir)
      end

      it "can read files" do
        test_file_path = "test_file.txt"
        test_content = "Hello, world!"
        File.write(File.join(temp_dir, test_file_path), test_content)

        result = shell_context.read_file(test_file_path)

        value(result).must_equal(test_content)
      end

      it "raises FileNotFoundError when file does not exist" do
        assert_raises(ShellContext::FileNotFoundError) do
          shell_context.read_file("non_existent_file.txt")
        end
      end
    end
  end
end
