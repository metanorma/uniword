# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Glossary
      # Body content of a document part (building block content)
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:doc_part_body>
      class DocPartBody < Lutaml::Model::Serializable
          attribute :content, :string

          xml do
            element 'doc_part_body'
            namespace Uniword::Ooxml::Namespaces::Glossary
            mixed_content

            map_element 'content', to: :content, render_nil: false
          end
      end
    end
end
