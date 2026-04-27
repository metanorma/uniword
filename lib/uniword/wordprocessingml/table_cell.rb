# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Table cell
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:tc>
    class TableCell < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST, before xml block
      attribute :properties, TableCellProperties
      attribute :paragraphs, Paragraph, collection: true, initialize_empty: true
      attribute :tables, Table, collection: true, initialize_empty: true

      # Non-serialized runtime flag: true if this cell originated from <th>
      attr_accessor :header

      # Convenience flat attributes for API access
      attribute :column_span, :integer
      attribute :row_span, :integer
      attribute :vertical_alignment, :string
      attribute :width, :integer
      attribute :background_color, :string

      xml do
        element "tc"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "tcPr", to: :properties, render_nil: false
        map_element "p", to: :paragraphs, render_nil: false
        map_element "tbl", to: :tables, render_nil: false
      end

      # Accept visitor
      def accept(visitor)
        visitor.visit_table_cell(self)
      end

      # Get cell text content
      #
      # @return [String] Combined text from all paragraphs
      def text
        paragraphs.map(&:text).join("\n")
      end

      # Set cell text content
      #
      # @param value [String] Text to set
      # @return [String] The text value
      def text=(value)
        paragraphs.clear
        para = Paragraph.new
        run = Run.new(text: value.to_s)
        para.runs << run
        paragraphs << para
        value
      end

      # Alias for column_span
      def colspan
        column_span
      end

      # Alias for column_span=
      def colspan=(value)
        self.column_span = value
      end

      # Alias for row_span
      def rowspan
        row_span
      end

      # Alias for row_span=
      def rowspan=(value)
        self.row_span = value
      end
    end
  end
end
