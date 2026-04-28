# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module WpDrawing
    # Relative Z-order position
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:relativeHeight>
    class RelativeHeight < Lutaml::Model::Serializable
      attribute :value, :integer

      xml do
        element "relativeHeight"
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

        map_content to: :value
      end
    end
  end
end
