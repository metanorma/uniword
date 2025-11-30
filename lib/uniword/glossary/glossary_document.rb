# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Root element for glossary documents containing term definitions and building blocks
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:glossary_document>
    class GlossaryDocument < Lutaml::Model::Serializable
      attribute :doc_parts, DocParts

      xml do
        element 'glossary_document'
        namespace Uniword::Ooxml::Namespaces::Glossary
        mixed_content

        map_element 'docParts', to: :doc_parts, render_nil: false
      end
    end
  end
end
