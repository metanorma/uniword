# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Effect list container
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:effectLst>
    class EffectList < Lutaml::Model::Serializable
      attribute :glow, Glow
      attribute :inner_shdw, InnerShadow
      attribute :outer_shdw, OuterShadow
      attribute :reflection, Reflection
      attribute :soft_edge, SoftEdge

      xml do
        element 'effectLst'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_element 'glow', to: :glow, render_nil: false
        map_element 'innerShdw', to: :inner_shdw, render_nil: false
        map_element 'outerShdw', to: :outer_shdw, render_nil: false
        map_element 'reflection', to: :reflection, render_nil: false
        map_element 'softEdge', to: :soft_edge, render_nil: false
      end
    end
  end
end
