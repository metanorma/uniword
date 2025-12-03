# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Office Math object - container for mathematical expressions
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:oMath>
    class OMath < Lutaml::Model::Serializable
      # Pattern 0: Attributes BEFORE xml mappings
      attribute :runs, MathRun, collection: true, default: -> { [] }
      attribute :functions, Function, collection: true, default: -> { [] }
      attribute :fractions, Fraction, collection: true, default: -> { [] }
      attribute :superscripts, Superscript, collection: true, default: -> { [] }
      attribute :subscripts, Subscript, collection: true, default: -> { [] }
      attribute :sub_superscripts, SubSuperscript, collection: true, default: -> { [] }
      attribute :delimiters, Delimiter, collection: true, default: -> { [] }
      attribute :radicals, Radical, collection: true, default: -> { [] }
      attribute :narys, Nary, collection: true, default: -> { [] }
      attribute :boxes, Box, collection: true, default: -> { [] }
      attribute :accents, Accent, collection: true, default: -> { [] }
      attribute :bars, Bar, collection: true, default: -> { [] }
      attribute :group_chars, GroupChar, collection: true, default: -> { [] }
      attribute :border_boxes, BorderBox, collection: true, default: -> { [] }
      attribute :matrices, Matrix, collection: true, default: -> { [] }
      attribute :equation_arrays, EquationArray, collection: true, default: -> { [] }

      xml do
        element 'oMath'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'r', to: :runs, render_nil: false
        map_element 'func', to: :functions, render_nil: false
        map_element 'f', to: :fractions, render_nil: false
        map_element 'sSup', to: :superscripts, render_nil: false
        map_element 'sSub', to: :subscripts, render_nil: false
        map_element 'sSubSup', to: :sub_superscripts, render_nil: false
        map_element 'd', to: :delimiters, render_nil: false
        map_element 'rad', to: :radicals, render_nil: false
        map_element 'nary', to: :narys, render_nil: false
        map_element 'box', to: :boxes, render_nil: false
        map_element 'acc', to: :accents, render_nil: false
        map_element 'bar', to: :bars, render_nil: false
        map_element 'groupChr', to: :group_chars, render_nil: false
        map_element 'borderBox', to: :border_boxes, render_nil: false
        map_element 'm', to: :matrices, render_nil: false
        map_element 'eqArr', to: :equation_arrays, render_nil: false
      end
    end
  end
end
