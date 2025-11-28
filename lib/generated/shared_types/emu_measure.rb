# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module SharedTypes
      # Measurement in EMUs (English Metric Units, 1/914400 of an inch)
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:emu_measure>
      class EmuMeasure < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'emu_measure'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes', 'st'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
