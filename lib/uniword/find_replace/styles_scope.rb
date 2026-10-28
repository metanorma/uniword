# frozen_string_literal: true

module Uniword
  module FindReplace
    # Styles scope: text in style display names (`<w:name w:val=...>`
    # inside `word/styles.xml`).
    #
    # Style identifiers (`w:styleId`) are deliberately not touched —
    # renaming a styleId breaks every reference. Use
    # `DocumentRoot#rename_style` for that, which keeps references
    # intact.
    class StylesScope < Scope
      # @return [Symbol]
      def name
        :styles
      end

      # @yieldparam name_element [Wordprocessingml::StyleName]
      # @yieldparam accessor [Scope::TextAccessor]
      def each_text_node
        styles = @document.styles_configuration&.styles
        return unless styles

        styles.each do |style|
          name_element = style.name
          next unless name_element
          next unless name_element.val

          accessor = TextAccessor.new(
            -> { name_element.val },
            ->(value) { name_element.val = value },
          )
          yield name_element, accessor
        end
      end
    end
  end
end
