# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML image data reference
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:imagedata>
      class Imagedata < Lutaml::Model::Serializable
          attribute :src, String
          attribute :relid, String
          attribute :title, String
          attribute :croptop, String
          attribute :cropbottom, String
          attribute :cropleft, String
          attribute :cropright, String

          xml do
            root 'imagedata'
            namespace 'urn:schemas-microsoft-com:vml', 'v'

            map_attribute 'true', to: :src
            map_attribute 'true', to: :relid
            map_attribute 'true', to: :title
            map_attribute 'true', to: :croptop
            map_attribute 'true', to: :cropbottom
            map_attribute 'true', to: :cropleft
            map_attribute 'true', to: :cropright
          end
      end
    end
  end
end
