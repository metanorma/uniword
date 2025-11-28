# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Glossary
      # Gallery categorization for document parts
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:doc_part_gallery>
      class DocPartGallery < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'doc_part_gallery'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/glossary', 'g'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
