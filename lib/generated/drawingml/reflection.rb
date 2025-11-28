# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Reflection effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:reflection>
      class Reflection < Lutaml::Model::Serializable
          attribute :blur_rad, Integer
          attribute :st_a, Integer
          attribute :end_a, Integer
          attribute :dist, Integer

          xml do
            root 'reflection'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :blur_rad
            map_attribute 'true', to: :st_a
            map_attribute 'true', to: :end_a
            map_attribute 'true', to: :dist
          end
      end
    end
  end
end
