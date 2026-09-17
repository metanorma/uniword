# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Picture
    # Stretch fill properties
    #
    # Generated from OOXML schema: picture.yml
    # Element: <a:stretch> (CT_BlipFillProperties reuses DrawingML
    # children inside pic:blipFill)
    class PictureStretch < Lutaml::Model::Serializable
      attribute :fill_rect, FillRect

      xml do
        element "stretch"
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_element "fillRect", to: :fill_rect, render_nil: false
      end
    end
  end
end
