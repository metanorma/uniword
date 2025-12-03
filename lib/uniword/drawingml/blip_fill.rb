# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Picture fill properties
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:blipFill>
    class BlipFill < Lutaml::Model::Serializable
      attribute :rot_with_shape, :integer
      attribute :blip, Blip
      attribute :stretch, Stretch
      attribute :tile, Tile

      xml do
        element 'blipFill'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_attribute 'rotWithShape', to: :rot_with_shape, render_nil: false
        map_element 'blip', to: :blip, render_nil: false
        map_element 'stretch', to: :stretch, render_nil: false
        map_element 'tile', to: :tile, render_nil: false
      end
    end
  end
end
