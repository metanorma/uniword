# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module SharedTypes
    # Measurement in pixels
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:pixel_measure>
    class PixelMeasure < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element 'pixel_measure'
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute 'val', to: :val
      end
    end
  end
end
