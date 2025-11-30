# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Math run formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:rPr>
      class MathRunProperties < Lutaml::Model::Serializable
          attribute :lit, String
          attribute :nor, String
          attribute :scr, String
          attribute :sty, String
          attribute :brk, MathBreak
          attribute :aln, String

          xml do
            element 'rPr'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_attribute 'val', to: :lit
            map_attribute 'val', to: :nor
            map_attribute 'val', to: :scr
            map_attribute 'val', to: :sty
            map_element 'brk', to: :brk, render_nil: false
            map_attribute 'val', to: :aln
          end
      end
    end
end
