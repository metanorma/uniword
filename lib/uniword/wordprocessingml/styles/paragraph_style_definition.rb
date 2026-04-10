# frozen_string_literal: true

module Uniword
  module Styles
    # Paragraph style definition
    #
    # Responsibility: Hold paragraph-specific style properties
    # Single Responsibility: Paragraph style configuration only
    #
    # Defines formatting properties for paragraphs including alignment,
    # spacing, indentation, and default run properties.
    class ParagraphStyleDefinition < StyleDefinition
      attr_reader :next_style, :run_properties

      def initialize(config)
        super
        @next_style = config[:next_style]
        @run_properties = config[:run_properties] || {}
      end

      # Resolve inherited properties including run properties
      #
      # @param library [StyleLibrary] The style library to resolve base styles from
      # @return [Hash] Merged properties including base style properties
      def resolve_inheritance(library = nil)
        return full_properties unless @base_style && library

        base_def = library.paragraph_style(@base_style)
        base_props = base_def.resolve_inheritance(library)

        {
          properties: merge_properties(base_props[:properties], properties),
          run_properties: merge_properties(base_props[:run_properties], @run_properties)
        }
      end

      # Get all properties including run properties
      #
      # @return [Hash] All style properties
      def full_properties
        {
          properties: properties,
          run_properties: @run_properties
        }
      end

      protected

      def style_type
        :paragraph_style
      end
    end
  end
end
