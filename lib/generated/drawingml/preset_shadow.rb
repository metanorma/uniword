# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Preset shadow effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:prstShdw>
      class PresetShadow < Lutaml::Model::Serializable
          attribute :prst, String
          attribute :dist, Integer
          attribute :dir, Integer

          xml do
            root 'prstShdw'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :prst
            map_attribute 'true', to: :dist
            map_attribute 'true', to: :dir
          end
      end
    end
  end
end
