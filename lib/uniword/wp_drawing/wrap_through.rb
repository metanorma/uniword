# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module WpDrawing
    # Through text wrapping
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:wrapThrough>
    class WrapThrough < Lutaml::Model::Serializable
      attribute :wrap_text, :string
      attribute :dist_l, :integer
      attribute :dist_r, :integer
      attribute :wrap_polygon, :string

      xml do
        element "wrapThrough"
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute "wrap-text", to: :wrap_text
        map_attribute "dist-l", to: :dist_l
        map_attribute "dist-r", to: :dist_r
        map_element "wrapPolygon", to: :wrap_polygon, render_nil: false
      end
    end
  end
end
