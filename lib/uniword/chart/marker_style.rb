# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Marker style
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:markerStyle>
    class MarkerStyle < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'markerStyle'
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute 'val', to: :val
      end
    end
  end
end
