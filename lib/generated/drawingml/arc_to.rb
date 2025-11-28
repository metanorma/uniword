# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Arc to command
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:arcTo>
      class ArcTo < Lutaml::Model::Serializable
          attribute :wR, String
          attribute :hR, String
          attribute :stAng, String
          attribute :swAng, String

          xml do
            root 'arcTo'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :wR
            map_attribute 'true', to: :hR
            map_attribute 'true', to: :stAng
            map_attribute 'true', to: :swAng
          end
      end
    end
  end
end
