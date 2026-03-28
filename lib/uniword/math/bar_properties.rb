# frozen_string_literal: true

require 'lutaml/model'
require_relative 'math_simple_val'

module Uniword
  module Math
    # Bar formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:barPr>
    class BarProperties < Lutaml::Model::Serializable
      attribute :pos, MathSimpleVal
      attribute :ctrl_pr, ControlProperties

      xml do
        element 'barPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'pos', to: :pos, render_nil: false
        map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
      end
    end
  end
end
