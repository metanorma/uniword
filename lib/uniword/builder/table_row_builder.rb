# frozen_string_literal: true

module Uniword
  module Builder
    # Builds and configures TableRow objects.
    #
    # @example Create a table row
    #   t.row do |r|
    #     r.cell(text: 'Header 1')
    #     r.cell(text: 'Header 2')
    #   end
    class TableRowBuilder
      attr_reader :model

      def initialize(model = nil)
        @model = model || Wordprocessingml::TableRow.new
      end

      # Wrap an existing TableRow model
      def self.from_model(model)
        new(model)
      end

      # Create and add a cell to the row
      #
      # @param text [String, nil] Optional text content (creates a paragraph)
      # @yield [TableCellBuilder] Builder for cell configuration
      # @return [TableCellBuilder] The cell builder
      def cell(text: nil, &block)
        c = TableCellBuilder.new
        c << text if text
        yield(c) if block
        @model.cells << c.build
        c
      end

      # Set row height
      #
      # @param value [Integer] Height in twips
      # @param rule [String] Height rule ('auto', 'exact', 'atLeast')
      # @return [self]
      def height(value, rule: nil)
        @model.properties ||= Wordprocessingml::TableRowProperties.new
        @model.properties.height = value
        @model.properties.height_rule = rule if rule
        self
      end

      # Set as table header row
      #
      # @param value [Boolean] Header row state (default true)
      # @return [self]
      def header_row(value = true)
        @model.properties ||= Wordprocessingml::TableRowProperties.new
        @model.properties.table_header = value
        self
      end

      # Return the underlying TableRow model
      def build
        @model
      end
    end
  end
end
