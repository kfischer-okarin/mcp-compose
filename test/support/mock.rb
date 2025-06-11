# frozen_string_literal: true

class Mock
  attr_reader :mock

  def initialize(&block)
    @mock = MockRecorder.new
    @mock.instance_eval(&block) if block_given?
  end

  def method_missing(method_name, *args, **kwargs, &block)
    @mock.record_call(method_name, args, kwargs, block)

    if @mock.has_stub?(method_name)
      @mock.execute_stub(method_name, args, kwargs)
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
      @stub_list = []
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
      MethodStub.new(method_name, @stubs, @expectations, @stub_list)
    end

    def has_stub?(method_name)
      @stubs.key?(method_name) || @stub_list.any? { |stub| stub[:method] == method_name }
    end

    def execute_stub(method_name, args, kwargs)
      # First, try to find a stub that matches the exact arguments (search from end to find latest)
      matching_stub = @stub_list.reverse.find do |stub|
        stub[:method] == method_name &&
          stub[:args_matter] &&
          stub[:args] == args &&
          stub[:kwargs] == kwargs
      end

      # If no exact match found, use the default stub (without args)
      matching_stub ||= @stubs[method_name]

      return self unless matching_stub

      case matching_stub[:type]
      when :return
        matching_stub[:value]
      when :raise
        if matching_stub[:message]
          raise matching_stub[:exception_class], matching_stub[:message]
        else
          raise matching_stub[:exception_class]
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
    def initialize(method_name, stubs, expectations, stub_list)
      @method_name = method_name
      @stubs = stubs
      @expectations = expectations
      @stub_list = stub_list
      @current_expectation = nil
    end

    def returns(value)
      if @current_expectation && @current_expectation[:args_matter]
        # Add to stub_list for argument-specific stubs
        @stub_list << {
          method: @method_name,
          type: :return,
          value: value,
          args: @current_expectation[:args],
          kwargs: @current_expectation[:kwargs],
          args_matter: true
        }
      else
        # Use default stub for methods without specific arguments
        @stubs[@method_name] = {type: :return, value: value}
      end
      self
    end

    def raises(exception_class, message = nil)
      if @current_expectation && @current_expectation[:args_matter]
        # Add to stub_list for argument-specific stubs
        @stub_list << {
          method: @method_name,
          type: :raise,
          exception_class: exception_class,
          message: message,
          args: @current_expectation[:args],
          kwargs: @current_expectation[:kwargs],
          args_matter: true
        }
      else
        # Use default stub for methods without specific arguments
        @stubs[@method_name] = {type: :raise, exception_class: exception_class, message: message}
      end
      self
    end

    def expects_call
      @current_expectation = {
        method: @method_name,
        args_matter: false
      }
      @expectations << @current_expectation
      self
    end

    def expects_call_with(*args, **kwargs)
      @current_expectation = {
        method: @method_name,
        args: args,
        kwargs: kwargs,
        args_matter: true
      }
      @expectations << @current_expectation
      self
    end
  end
end
