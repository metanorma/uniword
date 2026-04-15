# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Delimiter object (parentheses, brackets, braces)
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:d>
    class Delimiter < Lutaml::Model::Serializable
      attribute :properties, DelimiterProperties
      attribute :elements, Element, collection: true, initialize_empty: true

      xml do
        element "d"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element "dPr", to: :properties, render_nil: false
        map_element "e", to: :elements, render_nil: false
      end
    end
  end
end
