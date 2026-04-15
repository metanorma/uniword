# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Generic wrapper for math elements with m:val attribute (string values)
    #
    # Reusable across all math property elements that follow the pattern:
    #   <m:elementName m:val="stringValue"/>
    #
    # The element name is determined by the parent's map_element key,
    # not by this class's root directive.
    class MathSimpleVal < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element "mathSimpleVal"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :value, render_nil: false
      end
    end
  end
end
