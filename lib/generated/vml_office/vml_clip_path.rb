# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Clip path for VML shapes
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:clippath>
      class VmlClipPath < Lutaml::Model::Serializable
          attribute :coords, String
          attribute :path, String

          xml do
            root 'clippath'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :coords
            map_attribute 'true', to: :path
          end
      end
    end
  end
end
