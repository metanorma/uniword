# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml2010
    # Text glow effect
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:glow>
    class TextGlow < Lutaml::Model::Serializable
      attribute :radius, :integer
      attribute :color, :string

      xml do
        element "glow"
        namespace Uniword::Ooxml::Namespaces::Word2010
        mixed_content

        map_attribute "radius", to: :radius
        map_element "color", to: :color, render_nil: false
      end
    end
  end
end
