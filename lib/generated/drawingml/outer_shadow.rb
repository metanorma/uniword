# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Outer shadow effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:outerShdw>
      class OuterShadow < Lutaml::Model::Serializable
          attribute :blur_rad, Integer
          attribute :dist, Integer
          attribute :dir, Integer
          attribute :algn, String

          xml do
            root 'outerShdw'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :blur_rad
            map_attribute 'true', to: :dist
            map_attribute 'true', to: :dir
            map_attribute 'true', to: :algn
          end
      end
    end
  end
end
