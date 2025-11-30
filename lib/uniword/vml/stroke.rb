# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML stroke properties
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:stroke>
      class Stroke < Lutaml::Model::Serializable
          attribute :color, String
          attribute :weight, String
          attribute :opacity, String
          attribute :linestyle, String
          attribute :joinstyle, String
          attribute :endcap, String
          attribute :true, String

          xml do
            element 'stroke'
            namespace Uniword::Ooxml::Namespaces::Vml

            map_attribute 'color', to: :color
            map_attribute 'weight', to: :weight
            map_attribute 'opacity', to: :opacity
            map_attribute 'linestyle', to: :linestyle
            map_attribute 'joinstyle', to: :joinstyle
            map_attribute 'endcap', to: :endcap
            map_attribute 'true', to: :true
          end
      end
    end
  end
end
