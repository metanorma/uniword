# frozen_string_literal: true

require 'lutaml/model'

module Uniword
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
            element 'fill'
            namespace Uniword::Ooxml::Namespaces::Vml

            map_attribute 'type', to: :type
            map_attribute 'true', to: :true
            map_attribute 'color', to: :color
            map_attribute 'opacity', to: :opacity
            map_attribute 'detectmouseclick', to: :detectmouseclick
            map_attribute 'relid', to: :relid
          end
      end
    end
end
