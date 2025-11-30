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
            element 'imagedata'
            namespace Uniword::Ooxml::Namespaces::Vml

            map_attribute 'src', to: :src
            map_attribute 'relid', to: :relid
            map_attribute 'title', to: :title
            map_attribute 'croptop', to: :croptop
            map_attribute 'cropbottom', to: :cropbottom
            map_attribute 'cropleft', to: :cropleft
            map_attribute 'cropright', to: :cropright
          end
      end
    end
  end
end
