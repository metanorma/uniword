# frozen_string_literal: true

require 'lutaml/model'

module Uniword
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
            element 'rule'
            namespace Uniword::Ooxml::Namespaces::Vml

            map_attribute 'id', to: :id
            map_attribute 'type', to: :type
            map_attribute 'data', to: :data
          end
      end
    end
end
