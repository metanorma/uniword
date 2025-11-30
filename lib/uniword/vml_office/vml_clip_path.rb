# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module VmlOffice
      # Clip path for VML shapes
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:clippath>
      class VmlClipPath < Lutaml::Model::Serializable
          attribute :coords, String
          attribute :path, String

          xml do
            element 'clippath'
            namespace Uniword::Ooxml::Namespaces::Vml

            map_attribute 'coords', to: :coords
            map_attribute 'path', to: :path
          end
      end
    end
end
