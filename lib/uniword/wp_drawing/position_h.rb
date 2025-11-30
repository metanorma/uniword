# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Horizontal positioning
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:positionH>
    class PositionH < Lutaml::Model::Serializable
      attribute :relative_from, String
      attribute :align, String
      attribute :pos_offset, Integer

      xml do
        element 'positionH'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute 'relative-from', to: :relative_from
        map_element '', to: :align, render_nil: false
        map_element 'posOffset', to: :pos_offset, render_nil: false
      end
    end
  end
end
