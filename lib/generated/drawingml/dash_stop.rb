# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Dash stop
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:ds>
      class DashStop < Lutaml::Model::Serializable
          attribute :d, Integer
          attribute :sp, Integer

          xml do
            root 'ds'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :d
            map_attribute 'true', to: :sp
          end
      end
    end
  end
end
