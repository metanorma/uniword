# frozen_string_literal: true

module Uniword
  module Redact
    # Built-in library of common PII patterns. Open/closed: callers
    # can register custom patterns via `PatternLibrary.register`.
    class PatternLibrary
      DEFAULT_PATTERNS = [
        # US Social Security Number: AAA-GG-SSSS (no all-zeros groups)
        Pattern.new(name: :ssn,
                    regex: /\b(?!000|666|9\d{2})\d{3}-(?!00)\d{2}-(?!0000)\d{4}\b/,
                    description: "US Social Security Number"),
        # Email address
        Pattern.new(name: :email,
                    regex: /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i,
                    description: "Email address"),
        # US phone: (555) 555-5555 or 555-555-5555
        Pattern.new(name: :phone,
                    regex: /\b\(?\d{3}\)?[-.\s]\d{3}[-.\s]\d{4}\b/,
                    description: "US phone number"),
        # Credit card number: 13-19 digits, optional separators
        Pattern.new(name: :credit_card,
                    regex: /\b(?:\d[ -]*?){13,19}\b/,
                    description: "Credit card number"),
        # IPv4 address
        Pattern.new(name: :ipv4,
                    regex: /\b(?:\d{1,3}\.){3}\d{1,3}\b/,
                    description: "IPv4 address"),
      ].freeze

      # All registered patterns, in registration order.
      #
      # @return [Array<Pattern>]
      def self.all
        DEFAULT_PATTERNS + @custom.to_a
      end

      # Select patterns by name.
      #
      # @param names [Array<Symbol>, :all] names to select, or :all
      # @return [Array<Pattern>]
      def self.select(names)
        return all if names == :all

        list = all
        Array(names).filter_map { |n| list.find { |p| p.name == n } }
      end

      # Register a custom pattern. Append-only.
      #
      # @param pattern [Pattern]
      # @return [void]
      def self.register(pattern)
        (@custom ||= []) << pattern
      end

      @custom = []
    end
  end
end
