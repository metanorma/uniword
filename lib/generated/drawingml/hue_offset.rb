# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Hue offset
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:hueOff>
      class HueOffset < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            root 'hueOff'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
