# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Glossary
      # Container for glossary document part entries (building blocks)
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:doc_parts>
      class DocParts < Lutaml::Model::Serializable
          attribute :doc_part, DocPart, collection: true, default: -> { [] }

          xml do
            root 'doc_parts'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/glossary', 'g'
            mixed_content

            map_element 'docPart', to: :doc_part, render_nil: false
          end
      end
    end
  end
end
