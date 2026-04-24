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
    class TableCellBuilder
      attr_reader :model

      def initialize(model = nil)
        @model = model || Wordprocessingml::TableCell.new
      end

      # Wrap an existing TableCell model
      def self.from_model(model)
        new(model)
      end

      # Append content to the cell. Routes by type:
      # - String → creates a Paragraph with a Run
      # - Paragraph → appends to paragraphs
      # - Table → appends to nested tables
      #
      # @param element [String, Paragraph, Table]
      # @return [self]
      def <<(element)
        case element
        when String
          para = Wordprocessingml::Paragraph.new
          para.runs << Wordprocessingml::Run.new(text: element)
          @model.paragraphs << para
        when Wordprocessingml::Paragraph
          @model.paragraphs << element
        when Wordprocessingml::Table
          @model.tables << element
        when ParagraphBuilder
          @model.paragraphs << element.build
        else
          raise ArgumentError, "Cannot add #{element.class} to table cell"
        end
        self
      end

      # Set cell shading
      #
      # @param fill [String] Fill color
      # @param color [String, nil] Shading color
      # @param pattern [String] Pattern (default 'clear')
      # @return [self]
      def shading(fill:, color: nil, pattern: "clear")
        ensure_cell_props
        @model.properties.shading = Properties::Shading.new(
          fill: fill, color: color, pattern: pattern,
        )
        self
      end

      # Set cell width
      #
      # @param value [Integer] Width in twips
      # @param rule [String] Width rule ('auto', 'exact', 'pct')
      # @return [self]
      def width(value, rule: nil)
        ensure_cell_props
        @model.properties.width ||= Properties::CellWidth.new
        @model.properties.width.value = value
        @model.properties.width.rule = rule if rule
        self
      end

      # Set vertical alignment
      #
      # @param value [String] :top, :center, :bottom, :both
      # @return [self]
      def vertical_align(value)
        ensure_cell_props
        @model.properties.vertical_align = Properties::CellVerticalAlign.new(value: value.to_s)
        self
      end

      # Set cell borders
      #
      # @param sides [Hash] Border specifications by side
      # @return [self]
      def borders(**sides)
        ensure_cell_props
        @model.properties.borders ||= Properties::Borders.new
        sides.each do |side, value|
          border = if value.is_a?(Hash)
                     Properties::Border.new(**value)
                   else
                     Properties::Border.new(color: value, style: "single",
                                            size: 4)
                   end
          @model.properties.borders.send("#{side}=", border)
        end
        self
      end

      # Set column span
      #
      # @param count [Integer] Number of columns to span
      # @return [self]
      def column_span(count)
        ensure_cell_props
        @model.properties.grid_span =
          Wordprocessingml::ValInt.new(value: count)
        self
      end

      # Set row span
      #
      # @param count [Integer] Number of rows to span
      # @return [self]
      def row_span(count)
        ensure_cell_props
        @model.properties.v_merge =
          Wordprocessingml::ValInt.new(value: count)
        self
      end

      # Return the underlying TableCell model
      def build
        @model
      end

      private

      def ensure_cell_props
        @model.properties ||= Wordprocessingml::TableCellProperties.new
      end
    end
  end
end
