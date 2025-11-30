# frozen_string_literal: true

module Uniword
  module Styles
    module DSL
      # List Context - DSL for list building
      #
      # Responsibility: Provide DSL methods for building lists
      # Single Responsibility: List item creation and styling only
      #
      # This context is used within the StyleBuilder#list method to provide
      # a fluent interface for adding list items with proper formatting.
      #
      # @example
      #   list :bullet_list do
      #     item "First point"
      #     item "Second point"
      #     item "Nested point", level: 1
      #   end
      class ListContext
        # Initialize list context
        #
        # @param document [Document] The document to add items to
        # @param list_style_def [ListStyleDefinition] The list style definition
        def initialize(document, list_style_def)
          @document = document
          @style_def = list_style_def
          @current_level = 0
        end

        # Add list item
        #
        # @param text [String] Item text content
        # @param level [Integer, nil] Nesting level (0-based, defaults to 0)
        # @return [Paragraph] The created paragraph
        #
        # @example
        #   item "First level item"
        #   item "Second level item", level: 1
        def item(text, level: nil)
          item_level = level || @current_level
          level_def = @style_def.level(item_level)

          para = Paragraph.new
          para.add_text(text)

          # Set numbering from style definition
          para.set_numbering(
            @style_def.numbering_definition,
            item_level
          )

          # Apply level-specific formatting if defined
          if level_def && level_def[:properties]
            para.properties = Properties::ParagraphProperties.new(
              **level_def[:properties], num_id: @style_def.numbering_definition,
                                        ilvl: item_level
            )
          end

          @document.add_paragraph(para)
          para
        end
      end
    end
  end
end
