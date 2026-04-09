# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Properties for a document part including name, category, and type
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:doc_part_properties>
    class DocPartProperties < Lutaml::Model::Serializable
      attribute :name, DocPartName
      attribute :style, StyleId
      attribute :category, DocPartCategory
      attribute :types, DocPartTypes
      attribute :behaviors, DocPartBehaviors
      attribute :description, DocPartDescription
      attribute :guid, DocPartId

      xml do
        root 'docPartPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'name', to: :name, render_nil: false
        map_element 'style', to: :style, render_nil: false
        map_element 'category', to: :category, render_nil: false
        map_element 'types', to: :types, render_nil: false
        map_element 'behaviors', to: :behaviors, render_nil: false
        map_element 'description', to: :description, render_nil: false
        map_element 'guid', to: :guid, render_nil: false
      end
    end
  end
end
