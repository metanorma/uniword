# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Relative Rectangle
    #
    # Complex type for a rectangle defined with percentage offsets.
    class RelativeRect < Lutaml::Model::Serializable
      attribute :l, :string
      attribute :t, :string
      attribute :r, :string
      attribute :b, :string

      xml do
        element 'rect'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'l', to: :l, render_nil: false
        map_attribute 't', to: :t, render_nil: false
        map_attribute 'r', to: :r, render_nil: false
        map_attribute 'b', to: :b, render_nil: false
      end
    end
  end
end
