# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # High-low lines
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:hiLowLines>
      class HiLowLines < Lutaml::Model::Serializable
          attribute :sp_pr, :string

          xml do
            element 'hiLowLines'
            namespace Uniword::Ooxml::Namespaces::Chart
            mixed_content

            map_element 'spPr', to: :sp_pr, render_nil: false
          end
      end
    end
end
