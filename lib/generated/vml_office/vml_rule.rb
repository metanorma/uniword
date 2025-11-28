# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Single layout rule
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:rule>
      class VmlRule < Lutaml::Model::Serializable
          attribute :id, String
          attribute :type, String
          attribute :data, String

          xml do
            root 'rule'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :type
            map_attribute 'true', to: :data
          end
      end
    end
  end
end
