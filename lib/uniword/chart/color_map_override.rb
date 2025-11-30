# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Color map override
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:clrMapOvr>
      class ColorMapOverride < Lutaml::Model::Serializable
          attribute :content, :string

          xml do
            element 'clrMapOvr'
            namespace Uniword::Ooxml::Namespaces::Chart

            map_element '', to: :content, render_nil: false
          end
      end
    end
end
