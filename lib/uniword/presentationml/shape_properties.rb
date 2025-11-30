# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Presentationml
      # Visual properties for shapes (fill, line, effects)
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:sp_pr>
      class ShapeProperties < Lutaml::Model::Serializable
          attribute :xfrm, :string
          attribute :custGeom, :string
          attribute :prst_geom, :string
          attribute :fill, :string
          attribute :ln, :string

          xml do
            element 'sp_pr'
            namespace Uniword::Ooxml::Namespaces::PresentationalML
            mixed_content

            map_element 'xfrm', to: :xfrm, render_nil: false
            map_element 'custGeom', to: :custGeom, render_nil: false
            map_element 'prstGeom', to: :prst_geom, render_nil: false
            map_element 'fill', to: :fill, render_nil: false
            map_element 'ln', to: :ln, render_nil: false
          end
      end
    end
end
