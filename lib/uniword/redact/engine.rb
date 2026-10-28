# frozen_string_literal: true

module Uniword
  module Redact
    # Redaction orchestrator. Runs each pattern through the
    # FindReplace engine and aggregates per-pattern counts.
    #
    # Open/closed: adding a new pattern = `PatternLibrary.register`
    # call. Engine unchanged.
    class Engine
      # @param document [Wordprocessingml::DocumentRoot]
      # @param patterns [Array<Pattern>, :pii] patterns to apply
      #   (`:pii` selects the default library)
      # @param scope [Symbol, Array<Symbol>, :all] find-replace scope
      def initialize(document:, patterns: :pii, scope: :all)
        @document = document
        @patterns = resolve_patterns(patterns)
        @scope = scope
      end

      # @return [Redact::Result]
      def run
        result = Result.new
        return result if @patterns.empty?

        @patterns.each do |pattern|
          matcher = FindReplace::RegexMatcher.new(pattern: pattern.regex,
                                                  replacement: pattern.replacement)
          fr = FindReplace::Engine.new(document: @document,
                                       matcher: matcher,
                                       scopes: @scope).run
          result.add(pattern.name, fr.count)
        end
        result
      end

      private

      def resolve_patterns(patterns)
        return PatternLibrary.all if patterns == :pii
        return [] if patterns.nil? || patterns.empty?

        list = Array(patterns)
        if list.all?(Symbol)
          PatternLibrary.select(list)
        else
          list
        end
      end
    end
  end
end
