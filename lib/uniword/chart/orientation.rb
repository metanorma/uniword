# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Axis orientation
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:orientation>
    class Orientation < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'orientation'
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute 'val', to: :val
      end
    end
  end
end
