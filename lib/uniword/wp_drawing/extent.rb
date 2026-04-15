# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module WpDrawing
    # Extent - Size of drawing object
    # Dimensions in EMUs (English Metric Units)
    class Extent < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :cx, :integer  # Width
      attribute :cy, :integer  # Height

      xml do
        element "extent"
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute "cx", to: :cx, render_nil: false
        map_attribute "cy", to: :cy, render_nil: false
      end
    end
  end
end
