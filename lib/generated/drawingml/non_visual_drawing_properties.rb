# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Non-visual drawing properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:cNvPr>
      class NonVisualDrawingProperties < Lutaml::Model::Serializable
          attribute :id, Integer
          attribute :name, String

          xml do
            root 'cNvPr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :name
          end
      end
    end
  end
end
