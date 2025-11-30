# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module VmlOffice
      # Left offset for VML elements
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:left>
      class VmlLeft < Lutaml::Model::Serializable
          attribute :value, String
          attribute :units, String

          xml do
            element 'left'
            namespace Uniword::Ooxml::Namespaces::Vml

            map_attribute 'value', to: :value
            map_attribute 'units', to: :units
          end
      end
    end
end
