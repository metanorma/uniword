# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Alpha bi-level effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:alphaBiLevel>
      class AlphaBiLevel < Lutaml::Model::Serializable
          attribute :thresh, Integer

          xml do
            root 'alphaBiLevel'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :thresh
          end
      end
    end
  end
end
