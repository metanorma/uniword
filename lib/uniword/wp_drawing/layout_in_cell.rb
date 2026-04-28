# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module WpDrawing
    # Layout object in table cell
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:layoutInCell>
    class LayoutInCell < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element "layoutInCell"
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

        map_content to: :value
      end
    end
  end
end
