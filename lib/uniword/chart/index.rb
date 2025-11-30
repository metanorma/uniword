# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Series index
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:idx>
    class Index < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element 'idx'
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute 'val', to: :val
      end
    end
  end
end
