# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Most Recently Used color list
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:colormru>
      class VmlColorMru < Lutaml::Model::Serializable
          attribute :ext, String
          attribute :colors, String

          xml do
            root 'colormru'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :ext
            map_attribute 'true', to: :colors
          end
      end
    end
  end
end
