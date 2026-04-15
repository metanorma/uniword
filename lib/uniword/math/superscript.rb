# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Superscript object
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:sSup>
    class Superscript < Lutaml::Model::Serializable
      attribute :properties, SuperscriptProperties
      attribute :element, Element
      attribute :sup, Sup

      xml do
        element "sSup"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element "sSupPr", to: :properties, render_nil: false
        map_element "e", to: :element
        map_element "sup", to: :sup
      end
    end
  end
end
