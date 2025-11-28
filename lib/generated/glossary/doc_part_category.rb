# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Glossary
      # Category classification for a document part
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:doc_part_category>
      class DocPartCategory < Lutaml::Model::Serializable
          attribute :name, CategoryName
          attribute :gallery, DocPartGallery

          xml do
            root 'doc_part_category'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/glossary', 'g'
            mixed_content

            map_element 'name', to: :name, render_nil: false
            map_element 'gallery', to: :gallery, render_nil: false
          end
      end
    end
  end
end
