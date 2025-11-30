# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module SharedTypes
      # Measurement in points
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:point_measure>
      class PointMeasure < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            element 'point_measure'
            namespace Uniword::Ooxml::Namespaces::SharedTypes

            map_attribute 'val', to: :val
          end
      end
    end
end
