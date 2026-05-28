# frozen_string_literal: true

module Uniword
  module Builder
    # Builds and configures TableCell objects.
    #
    # @example Create a table cell
    #   r.cell do |c|
    #     c << 'Cell content'
    #     c.shading(fill: '4472C4')
    #   end
    class TableCellBuilder < BaseBuilder
      include HasBorders
      include HasShading

      def self.default_model_class
        Wordprocessingml::TableCell
      end

      # Append content to the cell. Routes by type:
      # - String -> creates a Paragraph with a Run
      # - Paragraph -> appends to paragraphs
      # - Table -> appends to nested tables
      #
      # @param element [String, Paragraph, Table]
      # @return [self]
      def <<(element)
        case element
        when String
          para = Wordprocessingml::Paragraph.new
          para.runs << Wordprocessingml::Run.new(text: element)
          @model.paragraphs << para
          track_element_order("p")
        when Wordprocessingml::Paragraph
          @model.paragraphs << element
          track_element_order("p")
        when Wordprocessingml::Table
          @model.tables << element
          track_element_order("tbl")
        when ParagraphBuilder
          @model.paragraphs << element.build
          track_element_order("p")
        else
          raise ArgumentError, "Cannot add #{element.class} to table cell"
        end
        self
      end

      # Set cell width
      #
      # @param value [Integer] Width in twips
      # @param rule [String] Width rule ('auto', 'exact', 'pct')
      # @return [self]
      def width(value, rule: nil)
        ensure_properties
        @model.properties.width ||= Properties::CellWidth.new
        @model.properties.width.value = value
        @model.properties.width.rule = rule if rule
        self
      end

      def vertical_align(value)
        ensure_properties
        @model.properties.vertical_align = Properties::CellVerticalAlign.new(value: value.to_s)
        self
      end

      # Set column span
      #
      # @param count [Integer] Number of columns to span
      # @return [self]
      def column_span(count)
        ensure_properties
        @model.properties.grid_span =
          Wordprocessingml::ValInt.new(value: count)
        self
      end

      # Set row span
      #
      # @param count [Integer] Number of rows to span
      # @return [self]
      def row_span(count)
        ensure_properties
        @model.properties.v_merge =
          Wordprocessingml::ValInt.new(value: count)
        self
      end

      private

      def properties_tag
        "tcPr"
      end

      def ensure_properties
        @model.properties ||= Wordprocessingml::TableCellProperties.new
        ensure_properties_in_order
        @model.properties
      end
    end
  end
end
