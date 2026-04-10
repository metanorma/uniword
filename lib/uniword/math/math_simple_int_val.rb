# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Generic wrapper for math elements with m:val attribute (integer values)
    #
    # Reusable across all math property elements that follow the pattern:
    #   <m:elementName m:val="12345"/>
    #
    # The element name is determined by the parent's map_element key,
    # not by this class's root directive.
    class MathSimpleIntVal < Lutaml::Model::Serializable
      attribute :value, :integer

      xml do
        element 'mathSimpleIntVal'
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute 'val', to: :value, render_nil: false
      end
    end
  end
end
