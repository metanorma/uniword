# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'shd'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
            map_attribute 'true', to: :color
            map_attribute 'true', to: :fill
          end
      end
    end
  end
end
