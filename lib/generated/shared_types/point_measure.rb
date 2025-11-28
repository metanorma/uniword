# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module SharedTypes
      # Measurement in points
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:point_measure>
      class PointMeasure < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'point_measure'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes', 'st'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
