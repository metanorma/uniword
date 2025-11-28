# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # Text reflection effect
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:reflection>
      class TextReflection < Lutaml::Model::Serializable
          attribute :blur_radius, Integer
          attribute :start_opacity, Integer
          attribute :end_opacity, Integer
          attribute :distance, Integer

          xml do
            root 'reflection'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'

            map_attribute 'true', to: :blur_radius
            map_attribute 'true', to: :start_opacity
            map_attribute 'true', to: :end_opacity
            map_attribute 'true', to: :distance
          end
      end
    end
  end
end
