# frozen_string_literal: true

module Uniword
  module FindReplace
    # Body scope: text in `word/document.xml`. Walks every paragraph
    # reachable from the body (including paragraphs nested in table
    # cells and structured document tags).
    class BodyScope < Scope
      # @return [Symbol]
      def name
        :body
      end

      # @yieldparam text_element [Wordprocessingml::Text]
      # @yieldparam accessor [Scope::TextAccessor]
      def each_text_node
        return unless @document.body

        each_text_in_containers([@document.body]) { |*a| yield(*a) }
      end
    end
  end
end
