# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Matrix column properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:mc>
    class MatrixColumn < Lutaml::Model::Serializable
      attribute :column_properties, MatrixColumnProperties

      xml do
        element 'mc'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'mcPr', to: :column_properties, render_nil: false
      end
    end
  end
end
