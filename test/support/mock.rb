# frozen_string_literal: true

class Mock
  attr_reader :mock

  def initialize
    @mock = MockRecorder.new
  end

  def method_missing(method_name, *args, **kwargs, &block)
    @mock.record_call(method_name, args, kwargs, block)

    if @mock.has_stub?(method_name)
      @mock.execute_stub(method_name)
    else
      self
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    true
  end

  class MockRecorder
    attr_reader :calls

    def initialize
      @calls = []
      @stubs = {}
      @expectations = []
    end

    def record_call(method_name, args, kwargs, block)
      @calls << {
        method: method_name,
        args: args,
        kwargs: kwargs,
        block: block
      }
    end

    def method(method_name)
      MethodStub.new(method_name, @stubs, @expectations)
    end

    def has_stub?(method_name)
      @stubs.key?(method_name)
    end

    def execute_stub(method_name)
      stub = @stubs[method_name]
      case stub[:type]
      when :return
        stub[:value]
      when :raise
        if stub[:message]
          raise stub[:exception_class], stub[:message]
        else
          raise stub[:exception_class]
        end
      end
    end

    def assert_expected_calls_received
      @expectations.each do |expectation|
        if expectation[:args_matter]
          matching_call = @calls.find do |call|
            call[:method] == expectation[:method] &&
              call[:args] == expectation[:args] &&
              call[:kwargs] == expectation[:kwargs]
          end

          unless matching_call
            method_calls = @calls.select { |call| call[:method] == expectation[:method] }
            actual_calls_msg = if method_calls.empty?
              "Method '#{expectation[:method]}' was never called."
            else
              "Method '#{expectation[:method]}' was called #{method_calls.size} time(s) with:\n" +
                method_calls.map.with_index do |call, i|
                  "  #{i + 1}. args: #{call[:args].inspect}, kwargs: #{call[:kwargs].inspect}"
                end.join("\n")
            end

            raise <<~ERROR
              Expected #{expectation[:method]} to be called with args: #{expectation[:args].inspect}, kwargs: #{expectation[:kwargs].inspect}

              Actual calls:
              #{actual_calls_msg}

              All method calls:
              #{format_all_calls}
            ERROR
          end
        else
          matching_call = @calls.find { |call| call[:method] == expectation[:method] }

          unless matching_call
            raise <<~ERROR
              Expected #{expectation[:method]} to be called

              Actual calls:
              Method '#{expectation[:method]}' was never called.

              All method calls:
              #{format_all_calls}
            ERROR
          end
        end
      end
    end

    private

    def format_all_calls
      if @calls.empty?
        "  No methods were called"
      else
        @calls.map.with_index do |call, i|
          "  #{i + 1}. #{call[:method]}(#{format_call_args(call)})"
        end.join("\n")
      end
    end

    def format_call_args(call)
      parts = []
      parts << call[:args].map(&:inspect).join(", ") unless call[:args].empty?
      parts << call[:kwargs].map { |k, v| "#{k}: #{v.inspect}" }.join(", ") unless call[:kwargs].empty?
      parts.join(", ")
    end
  end

  class MethodStub
    def initialize(method_name, stubs, expectations)
      @method_name = method_name
      @stubs = stubs
      @expectations = expectations
    end

    def returns(value)
      @stubs[@method_name] = {type: :return, value: value}
      self
    end

    def raises(exception_class, message = nil)
      @stubs[@method_name] = {type: :raise, exception_class: exception_class, message: message}
      self
    end

    def expects_call
      @expectations << {
        method: @method_name,
        args_matter: false
      }
      self
    end

    def expects_call_with(*args, **kwargs)
      @expectations << {
        method: @method_name,
        args: args,
        kwargs: kwargs,
        args_matter: true
      }
      self
    end
  end
end
