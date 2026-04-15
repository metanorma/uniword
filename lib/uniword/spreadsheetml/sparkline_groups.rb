# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Sparkline groups collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:sparklineGroups>
    class SparklineGroups < Lutaml::Model::Serializable
      attribute :groups, SparklineGroup, collection: true, initialize_empty: true

      xml do
        element "sparklineGroups"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element "sparklineGroup", to: :groups, render_nil: false
      end
    end
  end
end
