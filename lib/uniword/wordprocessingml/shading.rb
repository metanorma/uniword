# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Shading pattern
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:shd>
      class Shading < Lutaml::Model::Serializable
          attribute :val, :string
          attribute :color, :string
          attribute :fill, :string

          xml do
            element 'shd'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
            map_attribute 'color', to: :color
            map_attribute 'fill', to: :fill
          end
      end
    end
end
