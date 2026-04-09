# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2010
    # Document part object for building blocks
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:docPartObj>
    class DocPartObj < Lutaml::Model::Serializable
      attribute :doc_part_gallery, DocPartGallery
      attribute :doc_part_category, :string
      attribute :doc_part_unique, :string

      xml do
        element 'docPartObj'
        namespace Uniword::Ooxml::Namespaces::Word2010
        mixed_content

        map_element 'docPartGallery', to: :doc_part_gallery, render_nil: false
        map_element 'docPartCategory', to: :doc_part_category, render_nil: false
        map_element 'docPartUnique', to: :doc_part_unique, render_nil: false
      end
    end
  end
end
