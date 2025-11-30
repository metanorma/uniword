# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Matrix column properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:mcs>
    class MatrixColumns < Lutaml::Model::Serializable
      attribute :columns, MatrixColumn, collection: true, default: -> { [] }

      xml do
        element 'mcs'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'mc', to: :columns, render_nil: false
      end
    end
  end
end
