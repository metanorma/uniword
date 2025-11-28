# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML fill properties
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:fill>
      class Fill < Lutaml::Model::Serializable
          attribute :type, String
          attribute :color, String
          attribute :color2, String
          attribute :opacity, String
          attribute :angle, String
          attribute :true, String

          xml do
            root 'fill'
            namespace 'urn:schemas-microsoft-com:vml', 'v'

            map_attribute 'true', to: :type
            map_attribute 'true', to: :color
            map_attribute 'true', to: :color2
            map_attribute 'true', to: :opacity
            map_attribute 'true', to: :angle
            map_attribute 'true', to: :true
          end
      end
    end
  end
end
