# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Text wrapping polygon
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:wrapPolygon>
    class WrapPolygon < Lutaml::Model::Serializable
      attribute :edited, :string
      attribute :start, :string
      attribute :line_to, :string, collection: true, initialize_empty: true

      xml do
        element 'wrapPolygon'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute 'edited', to: :edited
        map_element '', to: :start, render_nil: false
        map_element 'lineTo', to: :line_to, render_nil: false
      end
    end
  end
end
