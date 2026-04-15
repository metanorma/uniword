# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module WpDrawing
    # No text wrapping
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:wrapNone>
    class WrapNone < Lutaml::Model::Serializable
      xml do
        element "wrapNone"
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
      end
    end
  end
end
