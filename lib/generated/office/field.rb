# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Field properties
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:field>
      class Field < Lutaml::Model::Serializable
          attribute :type, String
          attribute :data, String

          xml do
            root 'field'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :type
            map_attribute 'true', to: :data
          end
      end
    end
  end
end
