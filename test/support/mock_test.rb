# frozen_string_literal: true

require_relative "../test_helper"
require_relative "mock"

describe Mock do
  it "records method calls" do
    mock = Mock.new

    mock.foo
    mock.bar(1, 2)
    mock.baz(name: "test")

    value(mock.mock.calls.size).must_equal 3
    value(mock.mock.calls[0]).must_equal({method: :foo, args: [], kwargs: {}, block: nil})
    value(mock.mock.calls[1]).must_equal({method: :bar, args: [1, 2], kwargs: {}, block: nil})
    value(mock.mock.calls[2]).must_equal({method: :baz, args: [], kwargs: {name: "test"}, block: nil})
  end

  it "responds to any method" do
    mock = Mock.new

    value(mock.respond_to?(:anything)).must_equal true
    value(mock.respond_to?(:something_else)).must_equal true
  end

  describe "stubbing" do
    it "allows stubbing methods to return values" do
      mock = Mock.new

      mock.mock.method(:my_method).returns(5)
      result = mock.my_method

      value(result).must_equal 5
    end

    it "still records calls for stubbed methods" do
      mock = Mock.new

      mock.mock.method(:my_method).returns(5)
      mock.my_method(1, 2)

      value(mock.mock.calls.size).must_equal 1
      value(mock.mock.calls[0][:method]).must_equal :my_method
      value(mock.mock.calls[0][:args]).must_equal [1, 2]
    end
  end

  it "records blocks passed to methods" do
    mock = Mock.new
    block = -> { "test" }

    mock.foo(&block)

    value(mock.mock.calls[0][:block]).must_be_same_as block
  end

  describe "expectations" do
    it "allows setting expectations before method calls" do
      mock = Mock.new

      mock.mock.method(:my_method).expects_call_with(5, and_a_kwarg: 33)
      mock.my_method(5, and_a_kwarg: 33)

      mock.mock.assert_expected_calls_received
    end

    it "allows expecting a call without specific arguments" do
      mock = Mock.new

      mock.mock.method(:my_method).expects_call
      mock.my_method(1, 2, 3)

      mock.mock.assert_expected_calls_received
    end

    it "raises when expected method was not called" do
      mock = Mock.new

      mock.mock.method(:my_method).expects_call_with(5)

      error = expect {
        mock.mock.assert_expected_calls_received
      }.must_raise RuntimeError
      value(error.message).must_include "Expected my_method to be called with args: [5]"
    end

    it "raises when method was called with wrong arguments" do
      mock = Mock.new

      mock.mock.method(:my_method).expects_call_with(5, and_a_kwarg: 33)
      mock.my_method(6, and_a_kwarg: 33)

      error = expect {
        mock.mock.assert_expected_calls_received
      }.must_raise RuntimeError
      value(error.message).must_include "Expected my_method to be called with args: [5], kwargs: {and_a_kwarg: 33}"
    end

    it "handles multiple expectations" do
      mock = Mock.new

      mock.mock.method(:first_method).expects_call_with(1)
      mock.mock.method(:second_method).expects_call_with(2)
      mock.first_method(1)
      mock.second_method(2)

      mock.mock.assert_expected_calls_received
    end

    it "allows expectations with return values" do
      mock = Mock.new

      mock.mock.method(:my_method).expects_call_with(5).returns(10)
      result = mock.my_method(5)

      value(result).must_equal 10
      mock.mock.assert_expected_calls_received
    end

    it "allows expects_call with return values" do
      mock = Mock.new

      mock.mock.method(:my_method).expects_call.returns(10)
      result = mock.my_method("anything", foo: "bar")

      value(result).must_equal 10
      mock.mock.assert_expected_calls_received
    end
  end

  describe "raising exceptions" do
    it "raises specified exception with message" do
      mock = Mock.new

      mock.mock.method(:error_method).raises(RuntimeError, "Something went wrong")

      error = expect {
        mock.error_method
      }.must_raise RuntimeError
      value(error.message).must_equal "Something went wrong"
    end

    it "raises specified exception without message" do
      mock = Mock.new

      mock.mock.method(:error_method).raises(RuntimeError)

      expect {
        mock.error_method
      }.must_raise RuntimeError
    end

    it "still records calls for methods that raise" do
      mock = Mock.new

      mock.mock.method(:error_method).raises(RuntimeError, "boom")

      expect { mock.error_method(1, 2) }.must_raise RuntimeError

      value(mock.mock.calls.size).must_equal 1
      value(mock.mock.calls[0][:method]).must_equal :error_method
      value(mock.mock.calls[0][:args]).must_equal [1, 2]
    end
  end
end
