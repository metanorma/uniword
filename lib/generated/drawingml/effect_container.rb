# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Effect DAG container
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:effectDag>
      class EffectContainer < Lutaml::Model::Serializable
          attribute :effects, String, collection: true, default: -> { [] }

          xml do
            root 'effectDag'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'effect', to: :effects, render_nil: false
          end
      end
    end
  end
end
