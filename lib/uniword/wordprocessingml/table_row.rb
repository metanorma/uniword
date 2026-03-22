# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Table row
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:tr>
    class TableRow < Lutaml::Model::Serializable
      attribute :properties, TableRowProperties
      attribute :cells, TableCell, collection: true, initialize_empty: true

      # Revision tracking attributes
      attribute :rsid_r, :string
      attribute :rsid_r_pr, :string
      attribute :rsid_tr, :string

      # W14 namespace attributes
      attribute :para_id, W14ParaId
      attribute :text_id, W14TextId

      # API compatibility - header flag for table rows
      attr_accessor :header

      xml do
        element 'tr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute 'rsidR', to: :rsid_r, render_nil: false
        map_attribute 'rsidRPr', to: :rsid_r_pr, render_nil: false
        map_attribute 'rsidTr', to: :rsid_tr, render_nil: false
        map_attribute 'paraId', to: :para_id, render_nil: false
        map_attribute 'textId', to: :text_id, render_nil: false

        map_element 'trPr', to: :properties, render_nil: false
        map_element 'tc', to: :cells, render_nil: false
      end

      # Add a cell to the row
      #
      # @param cell [TableCell, nil] Cell to add
      # @return [TableCell] The added cell
      def add_cell(cell = nil)
        cell ||= TableCell.new
        cells << cell
        cell
      end

      # Get cell count
      #
      # @return [Integer] Number of cells in row
      def cell_count
        cells.count
      end

      # Get row height
      #
      # @return [Integer, nil] Row height
      def height
        properties&.height
      end

      # Set row height
      #
      # @param value [Integer] Height value
      # @return [Integer] The height value
      def height=(value)
        self.properties ||= TableRowProperties.new
        properties.height = value
      end

      # Accept a visitor (Visitor pattern)
      #
      # @param visitor [BaseVisitor] The visitor to accept
      # @return [void]
      def accept(visitor)
        visitor.visit_table_row(self)
      end
    end
  end
end
