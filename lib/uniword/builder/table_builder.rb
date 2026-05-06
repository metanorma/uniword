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

      # Create and add a row to the table
      #
      # @yield [TableRowBuilder] Builder for row configuration
      # @return [TableRowBuilder] The row builder
      def row(&block)
        r = TableRowBuilder.new
        yield(r) if block
        @model.rows << r.build
        r
      end

      # Set table width
      #
      # @param value [Integer] Width in twips
      # @param rule [String] Width rule ('auto', 'exact', 'pct')
      # @return [self]
      def width(value, rule: nil)
        ensure_properties
        @model.properties.table_width ||= Properties::TableWidth.new
        @model.properties.table_width.value = value
        @model.properties.table_width.rule = rule if rule
        self
      end

      # Set table indentation
      #
      # @param value [Integer] Indent in twips
      # @return [self]
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

      def ensure_properties
        @model.properties ||= Wordprocessingml::TableProperties.new
        @model.properties
      end
    end
  end
end
