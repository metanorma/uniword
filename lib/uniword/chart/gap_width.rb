# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Gap width between bars/columns
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:gapWidth>
    class GapWidth < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "gapWidth"
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute "val", to: :val
      end
    end
  end
end
