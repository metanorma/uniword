# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Math paragraph properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:oMathParaPr>
    class OMathParaProperties < Lutaml::Model::Serializable
      attribute :justification, :string

      xml do
        element 'oMathParaPr'
        namespace Uniword::Ooxml::Namespaces::MathML

        map_attribute 'val', to: :justification
      end
    end
  end
end
