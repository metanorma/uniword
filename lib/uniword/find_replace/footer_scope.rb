# frozen_string_literal: true

module Uniword
  module FindReplace
    # Footers scope: text in every `word/footer*.xml`. Walks all
    # footer parts in the document's header-footer store.
    class FooterScope < Scope
      # @return [Symbol]
      def name
        :footers
      end

      # @yieldparam text_element [Wordprocessingml::Text]
      # @yieldparam accessor [Scope::TextAccessor]
      def each_text_node
        parts = @document.header_footer_parts
        return unless parts

        containers = parts.of_kind(:footer).filter_map(&:content)
        each_text_in_containers(containers) { |*a| yield(*a) }
      end
    end
  end
end
