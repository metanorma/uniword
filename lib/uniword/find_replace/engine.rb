# frozen_string_literal: true

module Uniword
  module FindReplace
    # Orchestrates a find-replace pass over a package.
    #
    # Owns the scope registry (which parts to scan) and matcher
    # dispatch (literal vs regex). Returns a `Result` with total
    # count and per-scope breakdown.
    #
    # Open/closed: scopes register in `SCOPE_REGISTRY`; adding one is
    # data, not behavior. The matcher class is chosen by the
    # `regex:` flag, but callers can pass a custom `Matcher` instance
    # to bypass the flag entirely.
    class Engine
      # Symbol => Scope subclass. Adding a scope = adding an entry.
      SCOPE_REGISTRY = {
        body: BodyScope,
        headers: HeaderScope,
        footers: FooterScope,
        footnotes: FootnoteScope,
        endnotes: EndnoteScope,
        comments: CommentScope,
        styles: StylesScope,
      }.freeze

      # All registered scope names. Used by `:all` to expand.
      ALL_SCOPES = SCOPE_REGISTRY.keys.freeze

      # @param document [Wordprocessingml::DocumentRoot]
      # @param matcher [Matcher]
      # @param scopes [Array<Symbol>, :all] scopes to scan; `:all`
      #   expands to every registered scope
      def initialize(document:, matcher:, scopes: :all)
        @document = document
        @matcher = matcher
        @scopes = resolve_scopes(scopes)
      end

      # Run the find-replace pass.
      #
      # @return [Result]
      def run
        result = Result.new
        return result if @matcher.nil? || @scopes.empty?

        @scopes.each do |scope_name|
          scope_class = SCOPE_REGISTRY.fetch(scope_name)
          scope = scope_class.new(@document)
          substitutions_in_scope = apply_scope(scope)
          result.add(scope_name, substitutions_in_scope)
        end
        result
      end

      private

      def resolve_scopes(scopes)
        return ALL_SCOPES if scopes == :all

        Array(scopes).select { |s| SCOPE_REGISTRY.key?(s) }
      end

      # Apply the matcher to every text accessor in one scope.
      #
      # @param scope [Scope]
      # @return [Integer] substitutions applied in this scope
      def apply_scope(scope)
        substitutions = 0
        scope.each_text_node do |_holder, accessor|
          original = accessor.value
          next unless original

          new_text, count = @matcher.apply(original)
          next if count.zero?

          accessor.value = new_text
          substitutions += count
        end
        substitutions
      end
    end
  end
end
