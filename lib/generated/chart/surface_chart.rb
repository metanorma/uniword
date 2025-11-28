# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Surface chart definition
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:surfaceChart>
      class SurfaceChart < Lutaml::Model::Serializable
          attribute :wireframe, :string
          attribute :series, :string, collection: true, default: -> { [] }
          attribute :band_fmts, :string
          attribute :ax_id, AxisId, collection: true, default: -> { [] }

          xml do
            root 'surfaceChart'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'wireframe', to: :wireframe, render_nil: false
            map_element 'ser', to: :series, render_nil: false
            map_element 'bandFmts', to: :band_fmts, render_nil: false
            map_element 'axId', to: :ax_id
          end
      end
    end
  end
end
