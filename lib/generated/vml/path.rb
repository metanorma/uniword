# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML path definition
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:path>
      class Path < Lutaml::Model::Serializable
          attribute :v, String
          attribute :textpathok, String
          attribute :fillok, String
          attribute :strokeok, String

          xml do
            root 'path'
            namespace 'urn:schemas-microsoft-com:vml', 'v'

            map_attribute 'true', to: :v
            map_attribute 'true', to: :textpathok
            map_attribute 'true', to: :fillok
            map_attribute 'true', to: :strokeok
          end
      end
    end
  end
end
