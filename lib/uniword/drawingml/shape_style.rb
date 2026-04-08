# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Shape Style
    #
    # Complex type for shape styling referencing style matrix entries.
    class ShapeStyle < Lutaml::Model::Serializable
      attribute :ln_ref, StyleMatrixReference
      attribute :fill_ref, StyleMatrixReference
      attribute :effect_ref, StyleMatrixReference
      attribute :font_ref, FontReference

      xml do
        element 'shapeStyle'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'lnRef', to: :ln_ref, render_nil: false
        map_element 'fillRef', to: :fill_ref, render_nil: false
        map_element 'effectRef', to: :effect_ref, render_nil: false
        map_element 'fontRef', to: :font_ref, render_nil: false
      end
    end
  end
end
