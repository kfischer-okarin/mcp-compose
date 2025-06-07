# frozen_string_literal: true

require "delegate"

module MCPCompose
  module Util
    # Adds a prefix to each line of output written to the underlying IO object.
    #
    # @param io [IO] the IO object to decorate
    # @param prefix [String] the prefix to add to each line
    class PrefixedIO < SimpleDelegator
      def initialize(io, prefix)
        super(io)
        @prefix = prefix
      end

      def puts(*args)
        if args.empty?
          __getobj__.puts("#{@prefix}")
        else
          args.each do |arg|
            __getobj__.puts("#{@prefix}#{arg}")
          end
        end
      end
    end
  end
end
