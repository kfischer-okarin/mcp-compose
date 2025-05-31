# frozen_string_literal: true

require_relative "lib/mcp_compose/version"

Gem::Specification.new do |spec|
  spec.name = "mcp_compose"
  spec.version = MCPCompose::VERSION
  spec.authors = ["Kevin Fischer"]
  spec.email = ["kfischer_okarin@yahoo.co.jp"]

  spec.summary = "MCP Server composition tool"
  spec.description = "A tool for composing MCP servers"
  spec.homepage = "https://github.com/kfischer-okarin/mcp-compose"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["source_code_uri"] = "https://github.com/kfischer-okarin/mcp-compose"
  spec.metadata["changelog_uri"] = "https://github.com/kfischer-okarin/mcp-compose/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*.rb"] + Dir["exe/*"] + ["README.md", "LICENSE"]
  spec.bindir = "exe"
  spec.executables = ["mcp-compose"]
  spec.require_paths = ["lib"]

  # Official MCP SDK
  spec.add_dependency "mcp", "~> 0.1.0"
  # JSON Schema validator
  spec.add_dependency "json_schemer", "~> 2.4"

  # Testing Framework
  spec.add_development_dependency "minitest", "~> 5.25"
  # Nice test outputs
  spec.add_development_dependency "minitest-reporters", "~> 1.7"
  # Task runner
  spec.add_development_dependency "rake", "~> 13.2"
  # Code formatting
  spec.add_development_dependency "standard", "~> 1.50"
end
