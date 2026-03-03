# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Math run formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:rPr>
    class MathRunProperties < Lutaml::Model::Serializable
      # Pattern 0: Attributes BEFORE xml mappings
      attribute :lit, :string
      attribute :nor, :string
      attribute :scr, :string
      attribute :sty, MathStyle
      attribute :brk, MathBreak
      attribute :aln, :string

      xml do
        element 'rPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        # Each is its own element
        map_element 'lit', to: :lit, render_nil: false
        map_element 'nor', to: :nor, render_nil: false
        map_element 'scr', to: :scr, render_nil: false
        map_element 'sty', to: :sty, render_nil: false
        map_element 'brk', to: :brk, render_nil: false
        map_element 'aln', to: :aln, render_nil: false
      end
    end
  end
end
