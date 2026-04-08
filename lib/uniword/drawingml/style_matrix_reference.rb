# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Style Matrix Reference
    #
    # Complex type for referencing style matrix entries with optional color override.
    class StyleMatrixReference < Lutaml::Model::Serializable
      attribute :idx, :integer
      attribute :scheme_clr, SchemeColor
      attribute :srgb_clr, SrgbColor

      xml do
        element 'lnRef'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'idx', to: :idx
        map_element 'schemeClr', to: :scheme_clr, render_nil: false
        map_element 'srgbClr', to: :srgb_clr, render_nil: false
      end
    end
  end
end
