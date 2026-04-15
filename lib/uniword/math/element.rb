# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Base element for math structures
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:e>
    class Element < Lutaml::Model::Serializable
      # Pattern 0: Attributes BEFORE xml mappings
      attribute :arg_properties, ArgumentProperties
      attribute :runs, MathRun, collection: true, initialize_empty: true
      attribute :functions, Function, collection: true, initialize_empty: true
      attribute :fractions, Fraction, collection: true, initialize_empty: true
      attribute :superscripts, Superscript, collection: true, initialize_empty: true
      attribute :subscripts, Subscript, collection: true, initialize_empty: true
      attribute :sub_superscripts, SubSuperscript, collection: true, initialize_empty: true
      attribute :delimiters, Delimiter, collection: true, initialize_empty: true
      attribute :radicals, Radical, collection: true, initialize_empty: true
      attribute :narys, Nary, collection: true, initialize_empty: true
      attribute :boxes, Box, collection: true, initialize_empty: true
      attribute :accents, Accent, collection: true, initialize_empty: true
      attribute :bars, Bar, collection: true, initialize_empty: true
      attribute :group_chars, GroupChar, collection: true, initialize_empty: true
      attribute :border_boxes, BorderBox, collection: true, initialize_empty: true
      attribute :matrices, Matrix, collection: true, initialize_empty: true
      attribute :equation_arrays, EquationArray, collection: true, initialize_empty: true

      xml do
        element "e"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element "argPr", to: :arg_properties, render_nil: false
        map_element "r", to: :runs, render_nil: false
        map_element "func", to: :functions, render_nil: false
        map_element "f", to: :fractions, render_nil: false
        map_element "sSup", to: :superscripts, render_nil: false
        map_element "sSub", to: :subscripts, render_nil: false
        map_element "sSubSup", to: :sub_superscripts, render_nil: false
        map_element "d", to: :delimiters, render_nil: false
        map_element "rad", to: :radicals, render_nil: false
        map_element "nary", to: :narys, render_nil: false
        map_element "box", to: :boxes, render_nil: false
        map_element "acc", to: :accents, render_nil: false
        map_element "bar", to: :bars, render_nil: false
        map_element "groupChr", to: :group_chars, render_nil: false
        map_element "borderBox", to: :border_boxes, render_nil: false
        map_element "m", to: :matrices, render_nil: false
        map_element "eqArr", to: :equation_arrays, render_nil: false
      end
    end
  end
end
