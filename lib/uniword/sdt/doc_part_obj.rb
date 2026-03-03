# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Sdt
    # Document Part Gallery for DocPartObj
    class DocPartGallery < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'docPartGallery'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false
      end
    end

    # Document Part Unique flag for DocPartObj (empty element)
    class DocPartUnique < Lutaml::Model::Serializable
      xml do
        element 'docPartUnique'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
      end
    end

    # Document Part Category for DocPartObj
    class DocPartCategory < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'docPartCategory'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :value, render_nil: false
      end
    end

    # Document Part Object reference in SDT properties
    # Reference XML: <w:docPartObj><w:docPartGallery w:val="..."/><w:docPartUnique/></w:docPartObj>
    class DocPartObj < Lutaml::Model::Serializable
      attribute :doc_part_gallery, DocPartGallery
      attribute :doc_part_category, DocPartCategory
      attribute :doc_part_unique, DocPartUnique

      xml do
        element 'docPartObj'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'docPartGallery', to: :doc_part_gallery, render_nil: false
        map_element 'docPartCategory', to: :doc_part_category, render_nil: false
        map_element 'docPartUnique', to: :doc_part_unique, render_nil: false
      end
    end
  end
end
