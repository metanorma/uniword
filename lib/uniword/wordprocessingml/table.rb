# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Table structure
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:tbl>
    class Table < Lutaml::Model::Serializable
      attribute :properties, TableProperties
      attribute :grid, TableGrid
      attribute :rows, TableRow, collection: true, initialize_empty: true
      attribute :alternate_content, AlternateContent, default: nil

      xml do
        element 'tbl'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'tblPr', to: :properties, render_nil: false
        map_element 'tblGrid', to: :grid, render_nil: false
        map_element 'tr', to: :rows, render_nil: false
        map_element 'AlternateContent', to: :alternate_content, render_nil: false
      end

      # Add a row to the table
      #
      # @param row [TableRow, nil] Row to add
      # @return [TableRow] The added row
      def add_row(row = nil)
        row ||= TableRow.new
        rows << row
        row
      end

      # Get row count
      #
      # @return [Integer] Number of rows in table
      def row_count
        rows.count
      end
    end
  end
end
