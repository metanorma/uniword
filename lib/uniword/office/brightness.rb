# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Office
      # Brightness setting
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:brightness>
      class Brightness < Lutaml::Model::Serializable
          attribute :value, String

          xml do
            element 'brightness'
            namespace Uniword::Ooxml::Namespaces::Office

            map_attribute 'value', to: :value
          end
      end
    end
end
