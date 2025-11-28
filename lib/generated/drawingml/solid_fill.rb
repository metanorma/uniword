# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Solid color fill
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:solidFill>
      class SolidFill < Lutaml::Model::Serializable


          xml do
            root 'solidFill'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

          end
      end
    end
  end
end
