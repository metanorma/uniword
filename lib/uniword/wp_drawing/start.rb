# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module WpDrawing
    # Wrapping polygon start point
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:start>
    class Start < Lutaml::Model::Serializable
      attribute :x, :integer
      attribute :y, :integer

      xml do
        element "start"
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

        map_attribute "x", to: :x
        map_attribute "y", to: :y
      end
    end
  end
end
