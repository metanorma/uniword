# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Hue value
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:hue>
      class Hue < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            root 'hue'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
