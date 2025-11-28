# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Line properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:ln>
      class LineProperties < Lutaml::Model::Serializable
          attribute :w, Integer

          xml do
            root 'ln'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :w
          end
      end
    end
  end
end
