# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Allow object overlap
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:allowOverlap>
    class AllowOverlap < Lutaml::Model::Serializable
      attribute :value, String

      xml do
        element 'allowOverlap'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

        map_element '', to: :value, render_nil: false
      end
    end
  end
end
