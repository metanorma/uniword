# frozen_string_literal: true

require 'lutaml/model'
require_relative 'math_simple_val'

module Uniword
  module Math
    # N-ary operator formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:naryPr>
    class NaryProperties < Lutaml::Model::Serializable
      attribute :chr, Char
      attribute :lim_loc, MathSimpleVal
      attribute :grow, MathSimpleVal
      attribute :sub_hide, MathSimpleVal
      attribute :sup_hide, MathSimpleVal
      attribute :ctrl_pr, ControlProperties

      xml do
        element 'naryPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'chr', to: :chr, render_nil: false
        map_element 'limLoc', to: :lim_loc, render_nil: false
        map_element 'grow', to: :grow, render_nil: false
        map_element 'subHide', to: :sub_hide, render_nil: false
        map_element 'supHide', to: :sup_hide, render_nil: false
        map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
      end
    end
  end
end
