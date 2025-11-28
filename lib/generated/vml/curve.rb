# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML curve shape
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:curve>
      class Curve < Lutaml::Model::Serializable
          attribute :id, String
          attribute :style, String
          attribute :from, String
          attribute :to, String
          attribute :control1, String
          attribute :control2, String
          attribute :strokecolor, String
          attribute :stroke, String

          xml do
            root 'curve'
            namespace 'urn:schemas-microsoft-com:vml', 'v'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :style
            map_attribute 'true', to: :from
            map_attribute 'true', to: :to
            map_attribute 'true', to: :control1
            map_attribute 'true', to: :control2
            map_attribute 'true', to: :strokecolor
            map_element '', to: :stroke, render_nil: false
          end
      end
    end
  end
end
