# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Bi-level (black and white) effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:biLevel>
      class BiLevel < Lutaml::Model::Serializable
          attribute :thresh, Integer

          xml do
            root 'biLevel'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :thresh
          end
      end
    end
  end
end
