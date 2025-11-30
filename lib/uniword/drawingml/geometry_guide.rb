# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Geometry guide
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:gd>
    class GeometryGuide < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :fmla, :string

      xml do
        element 'gd'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'name', to: :name
        map_attribute 'fmla', to: :fmla
      end
    end
  end
end
