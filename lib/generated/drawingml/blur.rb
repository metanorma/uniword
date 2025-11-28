# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Blur effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:blur>
      class Blur < Lutaml::Model::Serializable
          attribute :rad, Integer
          attribute :grow, String

          xml do
            root 'blur'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :rad
            map_attribute 'true', to: :grow
          end
      end
    end
  end
end
