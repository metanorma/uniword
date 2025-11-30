# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml2010
      # Document part gallery reference
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:docPartGallery>
      class DocPartGallery < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            element 'docPartGallery'
            namespace Uniword::Ooxml::Namespaces::Word2010

            map_attribute 'val', to: :val
          end
      end
    end
end
