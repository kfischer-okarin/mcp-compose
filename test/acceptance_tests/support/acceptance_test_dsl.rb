# frozen_string_literal: true

# This module contains the DSL for acceptance tests.
# Private methods that are not used to express the test cases should be
# defined in AcceptanceTestUtils.
module AcceptanceTestDSL
  def given_a_mcp_server(name, &block)
    ensure_base_dir_is_prepared
  end
end
