# frozen_string_literal: true

module Uniword
  module Redact
    # One redaction pattern: a regex plus a label that classifies the
    # kind of PII it matches.
    class Pattern
      attr_reader :name, :regex, :replacement, :description

      # @param name [Symbol] pattern identifier (e.g. :ssn, :email)
      # @param regex [Regexp] what to match
      # @param replacement [String] replacement text (default "[REDACTED]")
      # @param description [String] human-readable pattern description
      def initialize(name:, regex:, replacement: "[REDACTED]",
                     description: nil)
        @name = name
        @regex = regex
        @replacement = replacement
        @description = description
      end
    end
  end
end
