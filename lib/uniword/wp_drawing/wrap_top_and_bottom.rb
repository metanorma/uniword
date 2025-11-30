# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Top and bottom text wrapping
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:wrapTopAndBottom>
    class WrapTopAndBottom < Lutaml::Model::Serializable
      attribute :dist_t, Integer
      attribute :dist_b, Integer
      attribute :effect_extent, String

      xml do
        element 'wrapTopAndBottom'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute 'dist-t', to: :dist_t
        map_attribute 'dist-b', to: :dist_b
        map_element 'effectExtent', to: :effect_extent, render_nil: false
      end
    end
  end
end
