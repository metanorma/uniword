# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Office
      # Diffusity value
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:diffusity>
      class Diffusity < Lutaml::Model::Serializable
          attribute :value, String

          xml do
            element 'diffusity'
            namespace Uniword::Ooxml::Namespaces::Office

            map_attribute 'value', to: :value
          end
      end
    end
end
