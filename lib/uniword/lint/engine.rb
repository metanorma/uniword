# frozen_string_literal: true

module Uniword
  module Lint
    # Walks the document with each rule and aggregates findings.
    class Engine
      # @param document [Wordprocessingml::DocumentRoot]
      # @param ruleset [Ruleset, Array<Rule>] rules to apply
      def initialize(document:, ruleset:)
        @document = document
        @ruleset = wrap_ruleset(ruleset)
      end

      # @return [Result]
      def run
        result = Result.new
        @ruleset.rules.each do |rule|
          rule.check(@document) { |finding| result.add(finding) }
        end
        result
      end

      private

      def wrap_ruleset(ruleset)
        return ruleset if ruleset.is_a?(Ruleset)

        Ruleset.new(Array(ruleset))
      end
    end
  end
end
