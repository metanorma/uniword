# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Dash stop
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:ds>
      class DashStop < Lutaml::Model::Serializable
          attribute :d, Integer
          attribute :sp, Integer

          xml do
            element 'ds'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'd', to: :d
            map_attribute 'sp', to: :sp
          end
      end
    end
end
