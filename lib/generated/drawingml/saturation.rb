# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Saturation
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:sat>
      class Saturation < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            root 'sat'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
