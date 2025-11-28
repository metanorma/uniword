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
            root 'stroke'
            namespace 'urn:schemas-microsoft-com:vml', 'v'

            map_attribute 'true', to: :color
            map_attribute 'true', to: :weight
            map_attribute 'true', to: :opacity
            map_attribute 'true', to: :linestyle
            map_attribute 'true', to: :joinstyle
            map_attribute 'true', to: :endcap
            map_attribute 'true', to: :true
          end
      end
    end
  end
end
