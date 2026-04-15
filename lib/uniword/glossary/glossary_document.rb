# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Glossary
    # Root element for glossary documents containing term definitions and building blocks
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:glossary_document>
    class GlossaryDocument < Lutaml::Model::Serializable
      attribute :doc_parts, DocParts
      attribute :mc_ignorable, Uniword::Ooxml::Types::McIgnorable

      xml do
        root "glossaryDocument"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        namespace_scope [
          { namespace: Uniword::Ooxml::Namespaces::MarkupCompatibility,
            declare: :always }
        ]

        map_element "docParts", to: :doc_parts, render_nil: false
        # mc:Ignorable attribute from MarkupCompatibility namespace
        map_attribute "Ignorable", to: :mc_ignorable,
                                   render_nil: false
      end
    end
  end
end
