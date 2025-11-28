# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Effect list container
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:effectLst>
      class EffectList < Lutaml::Model::Serializable
          attribute :glow, Glow
          attribute :inner_shdw, InnerShadow
          attribute :outer_shdw, OuterShadow

          xml do
            root 'effectLst'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'glow', to: :glow, render_nil: false
            map_element 'innerShdw', to: :inner_shdw, render_nil: false
            map_element 'outerShdw', to: :outer_shdw, render_nil: false
          end
      end
    end
  end
end
