# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Presentationml
      # Handout master template for printed handouts
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:handout_master>
      class HandoutMaster < Lutaml::Model::Serializable
          attribute :c_sld, CommonSlideData
          attribute :clr_map, ColorMap

          xml do
            element 'handout_master'
            namespace Uniword::Ooxml::Namespaces::PresentationalML
            mixed_content

            map_element 'cSld', to: :c_sld
            map_element 'clrMap', to: :clr_map
          end
      end
    end
end
