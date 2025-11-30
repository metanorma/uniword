# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Office
      # Bottom position
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:bottom>
      class Bottom < Lutaml::Model::Serializable
          attribute :value, String

          xml do
            element 'bottom'
            namespace Uniword::Ooxml::Namespaces::Office

            map_attribute 'value', to: :value
          end
      end
    end
end
