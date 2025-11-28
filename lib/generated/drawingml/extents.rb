# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Shape extents
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:ext>
      class Extents < Lutaml::Model::Serializable
          attribute :cx, Integer
          attribute :cy, Integer

          xml do
            root 'ext'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :cx
            map_attribute 'true', to: :cy
          end
      end
    end
  end
end
