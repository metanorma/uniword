# frozen_string_literal: true

module Uniword
  module Builder
    # Builds and configures Table objects.
    #
    # @example Create a table
    #   doc.table do |t|
    #     t.row do |r|
    #       r.cell(text: 'Name')
    #       r.cell(text: 'Value')
    #     end
    #   end
    class TableBuilder < BaseBuilder
      include HasBorders
      include HasShading

      def self.default_model_class
        Wordprocessingml::Table
      end

      def initialize(model = nil)
        super
        ensure_table_structure
      end

      def row(&block)
        r = TableRowBuilder.new
        yield(r) if block
        @model.rows << r.build
        finalize_table_structure
        r
      end

      def width(value, rule: nil)
        ensure_properties
        @model.properties.table_width ||= Properties::TableWidth.new
        @model.properties.table_width.value = value
        @model.properties.table_width.rule = rule if rule
        self
      end

      def indent(value)
        ensure_properties
        @model.properties.table_indent ||= Properties::TableIndent.new
        @model.properties.table_indent.value = value
        self
      end

      def align=(value)
        ensure_properties
        @model.properties.justification = Properties::TableJustification.new(value: value.to_s)
        self
      end

      private

      def properties_tag
        "tblPr"
      end

      def ensure_properties
        @model.properties ||= Wordprocessingml::TableProperties.new
        ensure_properties_in_order
        @model.properties
      end

      def ensure_table_structure
        ensure_properties
        @model.properties.table_width ||= Properties::TableWidth.new(w: 0, type: "auto")
        @model.properties.table_look ||= Wordprocessingml::TableDefaults.default_table_look
      end

      def finalize_table_structure
        col_count = @model.rows.map(&:cell_count).max || 0
        return if col_count.zero?

        @model.grid ||= Wordprocessingml::TableGrid.new
        existing = @model.grid.columns.size
        if existing < col_count
          (col_count - existing).times do
            @model.grid.columns << Wordprocessingml::GridCol.new
          end
        elsif existing > col_count
          @model.grid.columns = @model.grid.columns.first(col_count)
        end
      end
    end
  end
end
