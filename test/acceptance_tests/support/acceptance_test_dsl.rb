# frozen_string_literal: true

module AcceptanceTestDSL
  def do_something
    # Implementation
  end

  def method_missing(name, *args, &block)
    message = <<~MESSAGE
      undefined DSL method `#{name}`

      Available methods:
    MESSAGE
    AcceptanceTestDSL.instance_methods(false).sort.each do |method|
      next if method == :method_missing

      message << "- #{method}\n"
    end
    skip(message)
  end
end
