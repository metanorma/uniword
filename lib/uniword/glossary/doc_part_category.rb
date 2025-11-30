# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Glossary
      # Category classification for a document part
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:doc_part_category>
      class DocPartCategory < Lutaml::Model::Serializable
          attribute :name, CategoryName
          attribute :gallery, DocPartGallery

          xml do
            element 'doc_part_category'
            namespace Uniword::Ooxml::Namespaces::Glossary
            mixed_content

            map_element 'name', to: :name, render_nil: false
            map_element 'gallery', to: :gallery, render_nil: false
          end
      end
    end
end
