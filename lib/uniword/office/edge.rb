# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Office
      # Edge properties
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:edge>
      class Edge < Lutaml::Model::Serializable
          attribute :color, String
          attribute :weight, String

          xml do
            element 'edge'
            namespace Uniword::Ooxml::Namespaces::Office

            map_attribute 'color', to: :color
            map_attribute 'weight', to: :weight
          end
      end
    end
end
