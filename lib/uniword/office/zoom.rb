# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Office
      # Zoom level
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:zoom>
      class Zoom < Lutaml::Model::Serializable
          attribute :percent, String

          xml do
            element 'zoom'
            namespace Uniword::Ooxml::Namespaces::Office

            map_attribute 'percent', to: :percent
          end
      end
    end
end
