# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "acceptance_test_dsl"

module Kernel
  # For grouping acceptance test scenarios around a particular feature.
  # Test cases inside are defined using the `scenario` method and have access
  # to the acceptance test DSL defined in AcceptanceTestDSL.
  def feature(desc, &block)
    describe(desc) do
      class << self
        alias_method :scenario, :it
      end

      include AcceptanceTestDSL

      instance_eval(&block)
    end
  end
end
