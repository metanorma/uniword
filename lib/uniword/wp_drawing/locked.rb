# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module WpDrawing
    # Lock anchor flag
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:locked>
    class Locked < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element "locked"
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

        map_content to: :value
      end
    end
  end
end
