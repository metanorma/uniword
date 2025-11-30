# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Show category name flag
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:showCatName>
    class ShowCategoryName < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'showCatName'
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute 'val', to: :val
      end
    end
  end
end
