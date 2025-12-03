# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Duotone effect
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:duotone>
    class Duotone < Lutaml::Model::Serializable
      attribute :scheme_colors, SchemeColor, collection: true, default: -> { [] }

      xml do
        element 'duotone'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_element 'schemeClr', to: :scheme_colors
      end
    end
  end
end
