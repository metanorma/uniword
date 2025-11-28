# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Chart element layout
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:layout>
      class Layout < Lutaml::Model::Serializable
          attribute :manual_layout, :string

          xml do
            root 'layout'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'manualLayout', to: :manual_layout, render_nil: false
          end
      end
    end
  end
end
