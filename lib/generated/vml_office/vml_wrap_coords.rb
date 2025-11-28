# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Text wrap coordinates
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:wrapcoords>
      class VmlWrapCoords < Lutaml::Model::Serializable
          attribute :coords, String

          xml do
            root 'wrapcoords'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :coords
          end
      end
    end
  end
end
