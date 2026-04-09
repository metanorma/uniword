# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Glossary
    # Gallery categorization for document parts
    #
    # Generated from OOXML schema: glossary.yml
    # Element: <g:doc_part_gallery>
    class DocPartGallery < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        root 'gallery'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
