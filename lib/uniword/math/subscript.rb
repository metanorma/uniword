# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Subscript object
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:sSub>
    class Subscript < Lutaml::Model::Serializable
      attribute :properties, SubscriptProperties
      attribute :element, Element
      attribute :sub, Sub

      xml do
        element "sSub"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element "sSubPr", to: :properties, render_nil: false
        map_element "e", to: :element
        map_element "sub", to: :sub
      end
    end
  end
end
