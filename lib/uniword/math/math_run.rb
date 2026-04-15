# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Math run - text with formatting
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:r>
    #
    # CRITICAL: Can contain BOTH m:rPr (Math properties) AND w:rPr (Word properties)
    class MathRun < Lutaml::Model::Serializable
      # Pattern 0: Attributes BEFORE xml mappings
      attribute :math_properties, MathRunProperties
      attribute :word_properties, Uniword::Wordprocessingml::RunProperties
      attribute :text, MathText

      xml do
        element "r"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        # Math-specific properties (m:rPr)
        # The MathRunProperties class declares its own MathML namespace
        map_element "rPr", to: :math_properties,
                           render_nil: false

        # WordprocessingML properties (w:rPr)
        # The RunProperties class declares its own WordProcessingML namespace
        # Note: In new lutaml-model, we can't specify namespace at mapping level
        # The target class's declared namespace is used instead
        map_element "rPr", to: :word_properties,
                           render_nil: false

        # Math text (m:t)
        map_element "t", to: :text,
                         render_nil: false
      end
    end
  end
end
