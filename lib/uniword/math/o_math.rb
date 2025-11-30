# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Office Math object - container for mathematical expressions
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:oMath>
    class OMath < Lutaml::Model::Serializable
      attribute :elements, :string, collection: true, default: -> { [] }

      xml do
        element 'oMath'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element '*', to: :elements, render_nil: false
      end
    end
  end
end
