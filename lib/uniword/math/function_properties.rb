# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Function formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:funcPr>
    class FunctionProperties < Lutaml::Model::Serializable
      attribute :ctrl_pr, ControlProperties

      xml do
        element 'funcPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
      end
    end
  end
end
