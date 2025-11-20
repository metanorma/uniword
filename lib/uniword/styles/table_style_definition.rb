# frozen_string_literal: true

require_relative "style_definition"

module Uniword
  module Styles
    # Table style definition
    #
    # Responsibility: Hold table-specific style properties
    # Single Responsibility: Table style configuration only
    #
    # Defines formatting properties for tables including borders,
    # cell spacing, cell padding, and conditional formatting.
    class TableStyleDefinition < StyleDefinition
      attr_reader :table_properties, :cell_properties, :conditional_formatting

      def initialize(config)
        super(config)
        @table_properties = config[:table_properties] || {}
        @cell_properties = config[:cell_properties] || {}
        @conditional_formatting = config[:conditional_formatting] || {}
      end

      # Resolve inherited properties for tables
      #
      # @param library [StyleLibrary] The style library to resolve base styles from
      # @return [Hash] Merged properties including base style properties
      def resolve_inheritance(library = nil)
        return full_properties unless @base_style && library

        base_def = library.table_style(@base_style)
        base_props = base_def.resolve_inheritance(library)

        {
          table_properties: merge_properties(base_props[:table_properties], @table_properties),
          cell_properties: merge_properties(base_props[:cell_properties], @cell_properties),
          conditional_formatting: merge_properties(
            base_props[:conditional_formatting],
            @conditional_formatting
          )
        }
      end

      # Get all properties
      #
      # @return [Hash] All style properties
      def full_properties
        {
          table_properties: @table_properties,
          cell_properties: @cell_properties,
          conditional_formatting: @conditional_formatting
        }
      end

      protected

      def style_type
        :table_style
      end
    end
  end
end