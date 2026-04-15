# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module WpDrawing
    # Relative horizontal size
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:sizeRelH>
    class SizeRelH < Lutaml::Model::Serializable
      attribute :relative_from, :string
      attribute :pct_width, :integer

      xml do
        element "sizeRelH"
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_attribute "relative-from", to: :relative_from
        map_element "pctWidth", to: :pct_width, render_nil: false
      end
    end
  end
end
