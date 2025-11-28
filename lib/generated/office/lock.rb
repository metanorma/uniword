# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Lock object properties
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:lock>
      class Lock < Lutaml::Model::Serializable
          attribute :text, String
          attribute :shapetype, String
          attribute :rotation, String
          attribute :aspectratio, String
          attribute :position, String

          xml do
            root 'lock'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :text
            map_attribute 'true', to: :shapetype
            map_attribute 'true', to: :rotation
            map_attribute 'true', to: :aspectratio
            map_attribute 'true', to: :position
          end
      end
    end
  end
end
