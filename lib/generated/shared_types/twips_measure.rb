# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module SharedTypes
      # Measurement in twips (1/20th of a point)
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:twips_measure>
      class TwipsMeasure < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'twips_measure'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes', 'st'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
