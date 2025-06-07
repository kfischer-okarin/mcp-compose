# frozen_string_literal: true

require_relative "../../test_helper"
require_relative "acceptance_test_dsl"
require_relative "acceptance_test_utils"
require_relative "fixtures"

module Kernel
  # For grouping acceptance test scenarios around a particular feature.
  # Test cases inside are defined using the `scenario` method and have access
  # to the acceptance test DSL defined in AcceptanceTestDSL.
  def feature(desc, &block)
    describe(desc) do
      class << self
        # @param desc [String] The description of the scenario.
        # @param wip [Boolean] Whether the scenario is a work in progress.
        #   If true, the scenario will be skipped as long as it fails.
        #   Once it starts to pass, it will be marked as a failure in the test
        #   suite, so the developer realizes that the WIP flag can be removed.
        # @param block [Proc] The test code to be executed.
        def scenario(desc, wip: false, &block)
          if wip
            it(desc) do
              passed = false
              error = nil

              begin
                instance_eval(&block)
                passed = true
              rescue Minitest::Assertion, StandardError => e
                error = e
              end

              if passed
                flunk "WIP test passed - remove the wip flag"
              else
                # Use Minitest's own error formatting
                bt = Minitest.filter_backtrace(error.backtrace)
                  .join("\n    ")
                  .gsub(%r{#{Dir.pwd}/}, "")
                skip <<~MESSAGE
                  WIP: #{error.class}: #{error.message}
                      #{bt}
                MESSAGE
              end
            end
          else
            it(desc, &block)
          end
        end
      end

      include AcceptanceTestDSL
      include AcceptanceTestUtils

      instance_eval(&block)
    end
  end
end
