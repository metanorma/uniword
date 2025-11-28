# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Sparkline group definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:sparklineGroup>
      class SparklineGroup < Lutaml::Model::Serializable
          attribute :type, String
          attribute :display_empty_cells_as, String

          xml do
            root 'sparklineGroup'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :type
            map_attribute 'true', to: :display_empty_cells_as
          end
      end
    end
  end
end
