# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Container for glossary document part entries (building blocks)
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:doc_parts>
    class DocParts < Lutaml::Model::Serializable
      attribute :doc_part, DocPart, collection: true, initialize_empty: true

      xml do
        root 'docParts'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_element 'docPart', to: :doc_part, render_nil: false
      end
    end
  end
end
