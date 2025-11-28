# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Geometry guide
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:gd>
      class GeometryGuide < Lutaml::Model::Serializable
          attribute :name, String
          attribute :fmla, String

          xml do
            root 'gd'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :name
            map_attribute 'true', to: :fmla
          end
      end
    end
  end
end
