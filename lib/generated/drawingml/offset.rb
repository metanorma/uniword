# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Position offset
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:false>
      class Offset < Lutaml::Model::Serializable
          attribute :x, Integer
          attribute :y, Integer

          xml do
            root 'false'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :x
            map_attribute 'true', to: :y
          end
      end
    end
  end
end
