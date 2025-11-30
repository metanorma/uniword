# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # N-ary operator formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:naryPr>
    class NaryProperties < Lutaml::Model::Serializable
      attribute :chr, Char
      attribute :lim_loc, String
      attribute :grow, String
      attribute :sub_hide, String
      attribute :sup_hide, String
      attribute :ctrl_pr, ControlProperties

      xml do
        element 'naryPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'chr', to: :chr, render_nil: false
        map_attribute 'val', to: :lim_loc
        map_attribute 'val', to: :grow
        map_attribute 'val', to: :sub_hide
        map_attribute 'val', to: :sup_hide
        map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
      end
    end
  end
end
