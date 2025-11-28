# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Luminance modulation
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:lumMod>
      class LuminanceModulation < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            root 'lumMod'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
