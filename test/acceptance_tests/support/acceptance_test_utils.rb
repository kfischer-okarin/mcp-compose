# frozen_string_literal: true

require "pathname"

# This module contains private utility methods for acceptance tests which are
# not listed among the available DSL methods.
module AcceptanceTestUtils
  private

  def ensure_base_dir_is_prepared
    @base_dir ||= Pathname.new(Dir.mktmpdir("mcp-compose-acceptance-tests"))
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
end
