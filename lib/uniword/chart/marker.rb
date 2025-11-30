# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Data marker
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:marker>
    class Marker < Lutaml::Model::Serializable
      attribute :symbol, MarkerStyle
      attribute :size, MarkerSize
      attribute :sp_pr, :string

      xml do
        element 'marker'
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element 'symbol', to: :symbol, render_nil: false
        map_element 'size', to: :size, render_nil: false
        map_element 'spPr', to: :sp_pr, render_nil: false
      end
    end
  end
end
