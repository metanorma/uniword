# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Stretch fill to shape bounds
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:stretch>
    class Stretch < Lutaml::Model::Serializable
      attribute :fill_rect, FillRect

      xml do
        element "stretch"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element "fillRect", to: :fill_rect, render_nil: false
      end
    end
  end
end
