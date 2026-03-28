# frozen_string_literal: true

require 'lutaml/model'
require_relative 'math_simple_val'

module Uniword
  module Math
    # Box formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:boxPr>
    class BoxProperties < Lutaml::Model::Serializable
      attribute :opEmu, MathSimpleVal
      attribute :no_break, MathSimpleVal
      attribute :diff, MathSimpleVal
      attribute :brk, MathBreak
      attribute :aln, MathSimpleVal
      attribute :ctrl_pr, ControlProperties

      xml do
        element 'boxPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'opEmu', to: :opEmu, render_nil: false
        map_element 'noBreak', to: :no_break, render_nil: false
        map_element 'diff', to: :diff, render_nil: false
        map_element 'brk', to: :brk, render_nil: false
        map_element 'aln', to: :aln, render_nil: false
        map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
      end
    end
  end
end
