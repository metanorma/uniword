# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # 3D rotation
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:rot>
    class Rotation < Lutaml::Model::Serializable
      attribute :lat, :integer
      attribute :lon, :integer
      attribute :rev, :integer

      xml do
        element 'rot'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'lat', to: :lat, render_nil: false
        map_attribute 'lon', to: :lon, render_nil: false
        map_attribute 'rev', to: :rev, render_nil: false
      end
    end
  end
end
