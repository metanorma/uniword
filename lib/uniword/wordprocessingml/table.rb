# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Table structure
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:tbl>
    class Table < Lutaml::Model::Serializable
      attribute :properties, Uniword::Ooxml::WordProcessingML::TableProperties
      attribute :grid, TableGrid
      attribute :rows, TableRow, collection: true, default: -> { [] }
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
    end
  end
end
