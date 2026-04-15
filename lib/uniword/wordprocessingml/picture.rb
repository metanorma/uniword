# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # VML picture object
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:pict>
    class Picture < Lutaml::Model::Serializable
      # Pattern 0: Attributes FIRST
      attribute :shape, Uniword::Vml::Shape
      attribute :shapetype, Uniword::Vml::Shapetype

      xml do
        root "pict"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # VML elements inside w:pict are in the VML namespace
        map_element "shape", to: :shape, render_nil: false
        map_element "shapetype", to: :shapetype, render_nil: false
      end
    end
  end
end
