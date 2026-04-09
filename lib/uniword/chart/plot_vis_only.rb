# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Plot visible data only
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:plotVisOnly>
    class PlotVisOnly < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'plotVisOnly'
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute 'val', to: :val
      end
    end
  end
end
