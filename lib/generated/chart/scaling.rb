# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Scaling properties
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:scaling>
      class Scaling < Lutaml::Model::Serializable
          attribute :log_base, :string
          attribute :orientation, Orientation
          attribute :max, :string
          attribute :min, :string

          xml do
            root 'scaling'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'logBase', to: :log_base, render_nil: false
            map_element 'orientation', to: :orientation, render_nil: false
            map_element 'max', to: :max, render_nil: false
            map_element 'min', to: :min, render_nil: false
          end
      end
    end
  end
end
