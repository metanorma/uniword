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
    class TableBuilder
      attr_reader :model

      def initialize(model = nil)
        @model = model || Wordprocessingml::Table.new
      end

      # Wrap an existing Table model
      def self.from_model(model)
        new(model)
      end

      # Create and add a row to the table
      #
      # @yield [TableRowBuilder] Builder for row configuration
      # @return [TableRowBuilder] The row builder
      def row(&block)
        r = TableRowBuilder.new
        block.call(r) if block_given?
        @model.rows << r.build
        r
      end

      # Set table width
      #
      # @param value [Integer] Width in twips
      # @param rule [String] Width rule ('auto', 'exact', 'pct')
      # @return [self]
      def width(value, rule: nil)
        ensure_table_props
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
        ensure_table_props
        @model.properties.table_indent ||= Properties::TableIndent.new
        @model.properties.table_indent.value = value
        self
      end

      # Set table borders
      #
      # @param sides [Hash] Border specifications by side
      # @return [self]
      def borders(**sides)
        ensure_table_props
        @model.properties.borders ||= Properties::Borders.new
        sides.each do |side, value|
          border = if value.is_a?(Hash)
                     Properties::Border.new(**value)
                   else
                     Properties::Border.new(color: value, style: "single", size: 4)
                   end
          @model.properties.borders.send("#{side}=", border)
        end
        self
      end

      # Set table shading
      #
      # @param fill [String] Fill color
      # @return [self]
      def shading(fill:)
        ensure_table_props
        @model.properties.shading = Properties::Shading.new(fill: fill)
        self
      end

      # Set table alignment
      #
      # @param value [String] :left, :center, :right
      # @return [self]
      def align=(value)
        ensure_table_props
        @model.properties.justification = Properties::TableJustification.new(value: value.to_s)
        self
      end

      # Return the underlying Table model
      def build
        @model
      end

      private

      def ensure_table_props
        @model.properties ||= Wordprocessingml::TableProperties.new
      end
    end
  end
end
