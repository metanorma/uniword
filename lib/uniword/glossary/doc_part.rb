# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Individual glossary entry with properties and content
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:doc_part>
    class DocPart < Lutaml::Model::Serializable
      attribute :doc_part_pr, DocPartProperties
      attribute :doc_part_body, DocPartBody

      xml do
        element 'doc_part'
        namespace Uniword::Ooxml::Namespaces::Glossary
        mixed_content

        map_element 'docPartPr', to: :doc_part_pr, render_nil: false
        map_element 'docPartBody', to: :doc_part_body, render_nil: false
      end
    end
  end
end
