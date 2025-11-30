# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Presentationml
      # Slide master template defining common elements and styles
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:sld_master>
      class SlideMaster < Lutaml::Model::Serializable
          attribute :c_sld, CommonSlideData
          attribute :clr_map, ColorMap
          attribute :sld_layout_id_lst, :string
          attribute :transition, Transition
          attribute :timing, Timing
          attribute :preserve, :string

          xml do
            element 'sld_master'
            namespace Uniword::Ooxml::Namespaces::PresentationalML
            mixed_content

            map_element 'cSld', to: :c_sld
            map_element 'clrMap', to: :clr_map
            map_element 'sldLayoutIdLst', to: :sld_layout_id_lst, render_nil: false
            map_element 'transition', to: :transition, render_nil: false
            map_element 'timing', to: :timing, render_nil: false
            map_attribute 'preserve', to: :preserve
          end
      end
    end
end
