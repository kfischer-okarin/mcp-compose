# frozen_string_literal: true

require "minitest/autorun"
require "minitest/reporters"

require_relative "../lib/mcp_compose"

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new
