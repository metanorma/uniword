# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Presentationml
    # Slide layout template
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:sld_layout>
    class SlideLayout < Lutaml::Model::Serializable
      attribute :c_sld, CommonSlideData
      attribute :clr_map_ovr, :string
      attribute :transition, Transition
      attribute :timing, Timing
      attribute :type, :string
      attribute :preserve, :string

      xml do
        element 'sld_layout'
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element 'cSld', to: :c_sld
        map_element 'clrMapOvr', to: :clr_map_ovr, render_nil: false
        map_element 'transition', to: :transition, render_nil: false
        map_element 'timing', to: :timing, render_nil: false
        map_attribute 'type', to: :type
        map_attribute 'preserve', to: :preserve
      end
    end
  end
end
