# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Enhanced fill properties for VML Office
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:fill>
      class VmlOfficeFill < Lutaml::Model::Serializable
          attribute :type, String
          attribute :true, String
          attribute :color, String
          attribute :opacity, String
          attribute :detectmouseclick, String
          attribute :relid, String

          xml do
            root 'fill'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :type
            map_attribute 'true', to: :true
            map_attribute 'true', to: :color
            map_attribute 'true', to: :opacity
            map_attribute 'true', to: :detectmouseclick
            map_attribute 'true', to: :relid
          end
      end
    end
  end
end
