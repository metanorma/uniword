# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Sub-superscript formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:sSubSupPr>
      class SubSuperscriptProperties < Lutaml::Model::Serializable
          attribute :aln_scr, String
          attribute :ctrl_pr, ControlProperties

          xml do
            element 'sSubSupPr'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_attribute 'val', to: :aln_scr
            map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
          end
      end
    end
end
