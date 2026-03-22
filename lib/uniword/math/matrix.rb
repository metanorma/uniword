# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Mathematical matrix
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:m>
    class Matrix < Lutaml::Model::Serializable
      attribute :properties, MatrixProperties
      attribute :rows, MatrixRow, collection: true, initialize_empty: true

      xml do
        element 'm'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'mPr', to: :properties, render_nil: false
        map_element 'mr', to: :rows, render_nil: false
      end
    end
  end
end
