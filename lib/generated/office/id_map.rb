# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # ID mapping
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:idmap>
      class IdMap < Lutaml::Model::Serializable
          attribute :ext, String
          attribute :data, String

          xml do
            root 'idmap'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :ext
            map_attribute 'true', to: :data
          end
      end
    end
  end
end
