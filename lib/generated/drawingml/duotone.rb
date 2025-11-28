# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Duotone effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:duotone>
      class Duotone < Lutaml::Model::Serializable
          attribute :colors, String, collection: true, default: -> { [] }

          xml do
            root 'duotone'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'color', to: :colors, render_nil: false
          end
      end
    end
  end
end
