# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Adjustment value list
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:avLst>
      class AdjustValueList < Lutaml::Model::Serializable
          attribute :guides, GeometryGuide, collection: true, default: -> { [] }

          xml do
            root 'avLst'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'gd', to: :guides, render_nil: false
          end
      end
    end
  end
end
