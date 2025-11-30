# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Matrix row
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:mr>
    class MatrixRow < Lutaml::Model::Serializable
      attribute :elements, Element, collection: true, default: -> { [] }

      xml do
        element 'mr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'e', to: :elements, render_nil: false
      end
    end
  end
end
