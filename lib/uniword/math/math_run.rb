# frozen_string_literal: true

require 'lutaml/model'

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
        element 'r'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        # Math-specific properties (m:rPr)
        map_element 'rPr', to: :math_properties,
                    namespace: Uniword::Ooxml::Namespaces::MathML,
                    render_nil: false

        # WordprocessingML properties (w:rPr)
        map_element 'rPr', to: :word_properties,
                    namespace: Uniword::Ooxml::Namespaces::WordProcessingML,
                    render_nil: false

        # Math text (m:t)
        map_element 't', to: :text,
                    namespace: Uniword::Ooxml::Namespaces::MathML,
                    render_nil: false
      end

      # Backwards compatibility getter
      def properties
        @math_properties
      end

      # Backwards compatibility setter
      def properties=(value)
        @math_properties = value
      end
    end
  end
end
