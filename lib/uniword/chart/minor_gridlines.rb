# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Minor gridlines
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:minorGridlines>
    class MinorGridlines < Lutaml::Model::Serializable
      attribute :sp_pr, :string

      xml do
        element 'minorGridlines'
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element 'spPr', to: :sp_pr, render_nil: false
      end
    end
  end
end
