# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Text body properties
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:bodyPr>
    class BodyProperties < Lutaml::Model::Serializable
      attribute :wrap, String

      xml do
        element 'bodyPr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'wrap', to: :wrap
      end
    end
  end
end
