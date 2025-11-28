# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Border formatting
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:border>
      class Border < Lutaml::Model::Serializable
          attribute :val, :string
          attribute :color, :string
          attribute :sz, :integer
          attribute :space, :integer
          attribute :shadow, :boolean

          xml do
            root 'border'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :val
            map_attribute 'true', to: :color
            map_attribute 'true', to: :sz
            map_attribute 'true', to: :space
            map_attribute 'true', to: :shadow
          end
      end
    end
  end
end
