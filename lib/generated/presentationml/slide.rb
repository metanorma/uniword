# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Individual presentation slide
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:sld>
      class Slide < Lutaml::Model::Serializable
          attribute :c_sld, CommonSlideData
          attribute :clr_map_ovr, :string
          attribute :transition, Transition
          attribute :timing, Timing
          attribute :show_master_sp, :string
          attribute :show_master_phAnim, :string

          xml do
            root 'sld'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'cSld', to: :c_sld
            map_element 'clrMapOvr', to: :clr_map_ovr, render_nil: false
            map_element 'transition', to: :transition, render_nil: false
            map_element 'timing', to: :timing, render_nil: false
            map_attribute 'showMasterSp', to: :show_master_sp
            map_attribute 'showMasterPhAnim', to: :show_master_phAnim
          end
      end
    end
  end
end
