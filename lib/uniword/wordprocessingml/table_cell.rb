# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Table cell
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:tc>
    class TableCell < Lutaml::Model::Serializable
      attribute :properties, TableCellProperties
      attribute :paragraphs, Paragraph, collection: true, default: -> { [] }
      attribute :tables, Table, collection: true, default: -> { [] }

      xml do
        element 'tc'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'tcPr', to: :properties, render_nil: false
        map_element 'p', to: :paragraphs, render_nil: false
        map_element 'tbl', to: :tables, render_nil: false
      end
    end
  end
end
