# frozen_string_literal: true

module Uniword
  module FindReplace
    # Footnotes scope: text in `word/footnotes.xml`. Walks every
    # footnote entry's paragraphs.
    class FootnoteScope < Scope
      # @return [Symbol]
      def name
        :footnotes
      end

      # @yieldparam text_element [Wordprocessingml::Text]
      # @yieldparam accessor [Scope::TextAccessor]
      def each_text_node
        entries = @document.footnotes&.footnote_entries
        return unless entries

        each_text_in_containers(entries) { |*a| yield(*a) }
      end
    end
  end
end
