# frozen_string_literal: true

module Uniword
  module FindReplace
    # Headers scope: text in every `word/header*.xml`. Walks all
    # header parts in the document's header-footer store.
    class HeaderScope < Scope
      # @return [Symbol]
      def name
        :headers
      end

      # @yieldparam text_element [Wordprocessingml::Text]
      # @yieldparam accessor [Scope::TextAccessor]
      def each_text_node
        parts = @document.header_footer_parts
        return unless parts

        containers = parts.of_kind(:header).filter_map(&:content)
        each_text_in_containers(containers) { |*a| yield(*a) }
      end
    end
  end
end
