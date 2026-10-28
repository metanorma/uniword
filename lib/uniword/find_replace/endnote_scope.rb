# frozen_string_literal: true

module Uniword
  module FindReplace
    # Endnotes scope: text in `word/endnotes.xml`. Walks every
    # endnote entry's paragraphs.
    class EndnoteScope < Scope
      # @return [Symbol]
      def name
        :endnotes
      end

      # @yieldparam text_element [Wordprocessingml::Text]
      # @yieldparam accessor [Scope::TextAccessor]
      def each_text_node
        entries = @document.endnotes&.endnote_entries
        return unless entries

        each_text_in_containers(entries) { |*a| yield(*a) }
      end
    end
  end
end
