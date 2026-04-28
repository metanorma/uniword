# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module WpDrawing
    # Hidden object flag
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:hidden>
    class Hidden < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element "hidden"
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

        map_content to: :value
      end
    end
  end
end
