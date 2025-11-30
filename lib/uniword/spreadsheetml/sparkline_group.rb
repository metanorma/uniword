# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Sparkline group definition
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:sparklineGroup>
    class SparklineGroup < Lutaml::Model::Serializable
      attribute :type, String
      attribute :display_empty_cells_as, String

      xml do
        element 'sparklineGroup'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'type', to: :type
        map_attribute 'display-empty-cells-as', to: :display_empty_cells_as
      end
    end
  end
end
