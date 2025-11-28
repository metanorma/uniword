# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Text glow effect
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:glow>
      class TextGlow < Lutaml::Model::Serializable
          attribute :radius, Integer
          attribute :color, String

          xml do
            root 'glow'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'
            mixed_content

            map_attribute 'true', to: :radius
            map_element 'color', to: :color, render_nil: false
          end
      end
    end
  end
end
