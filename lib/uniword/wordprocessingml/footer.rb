# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Footer content
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:ftr>
    class Footer < Lutaml::Model::Serializable
      attribute :paragraphs, Paragraph, collection: true, initialize_empty: true
      attribute :tables, Table, collection: true, initialize_empty: true

      xml do
        element "ftr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "p", to: :paragraphs, render_nil: false
        map_element "tbl", to: :tables, render_nil: false
      end
    end
  end
end
