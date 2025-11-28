# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Soft edge effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:softEdge>
      class SoftEdge < Lutaml::Model::Serializable
          attribute :rad, Integer

          xml do
            root 'softEdge'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :rad
          end
      end
    end
  end
end
