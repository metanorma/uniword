# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Inner shadow effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:innerShdw>
      class InnerShadow < Lutaml::Model::Serializable
          attribute :blur_rad, Integer
          attribute :dist, Integer
          attribute :dir, Integer

          xml do
            root 'innerShdw'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :blur_rad
            map_attribute 'true', to: :dist
            map_attribute 'true', to: :dir
          end
      end
    end
  end
end
