# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Linear gradient properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:lin>
      class LinearGradient < Lutaml::Model::Serializable
          attribute :ang, Integer
          attribute :scaled, String

          xml do
            root 'lin'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :ang
            map_attribute 'true', to: :scaled
          end
      end
    end
  end
end
