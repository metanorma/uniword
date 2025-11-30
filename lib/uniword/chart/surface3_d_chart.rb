# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # 3D surface chart definition
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:surface3DChart>
    class Surface3DChart < Lutaml::Model::Serializable
      attribute :wireframe, :string
      attribute :series, :string, collection: true, default: -> { [] }
      attribute :band_fmts, :string
      attribute :ax_id, AxisId, collection: true, default: -> { [] }

      xml do
        element 'surface3DChart'
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element 'wireframe', to: :wireframe, render_nil: false
        map_element 'ser', to: :series, render_nil: false
        map_element 'bandFmts', to: :band_fmts, render_nil: false
        map_element 'axId', to: :ax_id
      end
    end
  end
end
