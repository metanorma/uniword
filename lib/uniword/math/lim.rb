# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Limit content
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:lim>
    class Lim < Lutaml::Model::Serializable
      attribute :arg_properties, ArgumentProperties
      attribute :elements, String, collection: true, default: -> { [] }

      xml do
        element 'lim'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'argPr', to: :arg_properties, render_nil: false
        map_element '*', to: :elements, render_nil: false
      end
    end
  end
end
