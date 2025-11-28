# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Text shadow effect
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:shadow>
      class TextShadow < Lutaml::Model::Serializable
          attribute :blur_radius, Integer
          attribute :distance, Integer
          attribute :direction, Integer
          attribute :alignment, String

          xml do
            root 'shadow'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'

            map_attribute 'true', to: :blur_radius
            map_attribute 'true', to: :distance
            map_attribute 'true', to: :direction
            map_attribute 'true', to: :alignment
          end
      end
    end
  end
end
