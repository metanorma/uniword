# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Table grid column definitions
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:tblGrid>
    class TableGrid < Lutaml::Model::Serializable
      attribute :columns, GridCol, collection: true, initialize_empty: true

      xml do
        element "tblGrid"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "gridCol", to: :columns, render_nil: false
      end
    end
  end
end
