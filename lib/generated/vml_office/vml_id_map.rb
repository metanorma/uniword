# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # ID mapping for shapes
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:idmap>
      class VmlIdMap < Lutaml::Model::Serializable
          attribute :ext, String
          attribute :data, String

          xml do
            root 'idmap'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :ext
            map_attribute 'true', to: :data
          end
      end
    end
  end
end
