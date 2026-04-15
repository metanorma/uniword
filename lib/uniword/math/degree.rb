# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Radical degree
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:deg>
    class Degree < Lutaml::Model::Serializable
      # Pattern 0: Attributes BEFORE xml mappings
      attribute :arg_properties, ArgumentProperties
      attribute :runs, MathRun, collection: true, initialize_empty: true

      xml do
        element "deg"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element "argPr", to: :arg_properties, render_nil: false
        map_element "r", to: :runs, render_nil: false
      end
    end
  end
end
