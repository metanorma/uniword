# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Math paragraph properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:oMathParaPr>
    class OMathParaProperties < Lutaml::Model::Serializable
      attribute :justification, MathSimpleVal

      xml do
        element 'oMathParaPr'
        namespace Uniword::Ooxml::Namespaces::MathML

        map_element 'jc', to: :justification, render_nil: false
      end
    end
  end
end
