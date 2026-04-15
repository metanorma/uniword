# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module WpDrawing
    # Square text wrapping
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:wrapSquare>
    class WrapSquare < Lutaml::Model::Serializable
      attribute :wrap_text, :string
      attribute :dist_t, :integer
      attribute :dist_b, :integer
      attribute :dist_l, :integer
      attribute :dist_r, :integer
      attribute :effect_extent, :string

      xml do
        element "wrapSquare"
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute "wrap-text", to: :wrap_text
        map_attribute "dist-t", to: :dist_t
        map_attribute "dist-b", to: :dist_b
        map_attribute "dist-l", to: :dist_l
        map_attribute "dist-r", to: :dist_r
        map_element "effectExtent", to: :effect_extent, render_nil: false
      end
    end
  end
end
