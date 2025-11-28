# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Glossary
      # Behavioral properties for a document part
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:doc_part_behaviors>
      class DocPartBehaviors < Lutaml::Model::Serializable
          attribute :behavior, DocPartBehavior, collection: true, default: -> { [] }

          xml do
            root 'doc_part_behaviors'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/glossary', 'g'
            mixed_content

            map_element 'behavior', to: :behavior, render_nil: false
          end
      end
    end
  end
end
