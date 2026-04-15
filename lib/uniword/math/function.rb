# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Mathematical function (sin, cos, log, etc.)
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:func>
    class Function < Lutaml::Model::Serializable
      attribute :properties, FunctionProperties
      attribute :function_name, FunctionName
      attribute :element, Element

      xml do
        element "func"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element "funcPr", to: :properties, render_nil: false
        map_element "fName", to: :function_name
        map_element "e", to: :element
      end
    end
  end
end
