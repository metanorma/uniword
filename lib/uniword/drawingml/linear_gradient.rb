# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Linear gradient properties
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:lin>
    class LinearGradient < Lutaml::Model::Serializable
      attribute :ang, Integer
      attribute :scaled, String

      xml do
        element 'lin'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'ang', to: :ang
        map_attribute 'scaled', to: :scaled
      end
    end
  end
end
