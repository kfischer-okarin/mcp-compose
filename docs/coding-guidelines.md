# Coding Guidelines

This document contains guidelines for coding in this project.

## Table of Contents

- [Basic Development Commands](#basic-development-commands)
- [Unit Test Files](#unit-test-files)

## Basic Development Commands

```sh
# Run a specific test
bundle exec ruby path/to/test.rb
```

## Unit Test Files

- Use minitest/spec style with `value(actual).must_be expected` style
  expectations
- Use Arrange-Assert-Act style and separate the three parts with blank lines.
- When testing nested classes or modules, nest the describe block inside the
  actual parent class/module hierarchy.

### Example

```ruby
require_relative "../test_helper"

module MCPCompose
  describe Server do
    it "can handle requests" do
      server = Server.new

      result = server.handle_request("request")

      value(result).must_be "expected"
    end
  end
end
