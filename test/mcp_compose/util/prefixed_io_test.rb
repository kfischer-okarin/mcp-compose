# frozen_string_literal: true

require_relative "../../test_helper"
require "stringio"

module MCPCompose
  module Util
    describe PrefixedIO do
      it "adds prefix to puts output" do
        wrapped_io = StringIO.new
        prefix = "[PREFIX] "
        decorator = PrefixedIO.new(wrapped_io, prefix)

        decorator.puts("Hello, world!")

        value(wrapped_io.string).must_equal "[PREFIX] Hello, world!\n"
      end

      it "adds prefix to each line when puts is called with multiple arguments" do
        wrapped_io = StringIO.new
        prefix = "[TEST] "
        decorator = PrefixedIO.new(wrapped_io, prefix)

        decorator.puts("First line", "Second line")

        value(wrapped_io.string).must_equal "[TEST] First line\n[TEST] Second line\n"
      end

      it "delegates other methods normally" do
        wrapped_io = StringIO.new
        prefix = "[PREFIX] "
        decorator = PrefixedIO.new(wrapped_io, prefix)

        decorator.write("Direct write")
        decorator.print("Direct print")

        value(wrapped_io.string).must_equal "Direct writeDirect print"
      end

      it "responds to delegated methods" do
        wrapped_io = StringIO.new
        decorator = PrefixedIO.new(wrapped_io, "[PREFIX] ")

        value(decorator.respond_to?(:write)).must_equal true
        value(decorator.respond_to?(:print)).must_equal true
        value(decorator.respond_to?(:close)).must_equal true
      end

      it "handles empty puts correctly" do
        wrapped_io = StringIO.new
        prefix = "[INFO] "
        decorator = PrefixedIO.new(wrapped_io, prefix)

        decorator.puts

        value(wrapped_io.string).must_equal "[INFO] \n"
      end
    end
  end
end
