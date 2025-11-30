# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Effect DAG container
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:effectDag>
      class EffectContainer < Lutaml::Model::Serializable
          attribute :effects, String, collection: true, default: -> { [] }

          xml do
            element 'effectDag'
            namespace Uniword::Ooxml::Namespaces::DrawingML
            mixed_content

            map_element 'effect', to: :effects, render_nil: false
          end
      end
    end
end
