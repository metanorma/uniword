# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module SharedTypes
      # Measurement in pixels
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:pixel_measure>
      class PixelMeasure < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'pixel_measure'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes', 'st'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
