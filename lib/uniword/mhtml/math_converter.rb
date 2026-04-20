# frozen_string_literal: true

module Uniword
  module Mhtml
    # Converts mathematical content between formats for MHTML.
    #
    # Responsibility: Convert MathML and AsciiMath to Word's OOXML math
    # format (OMML) for proper rendering in Microsoft Word. This class
    # handles math content serialization with graceful fallbacks.
    #
    # Supports:
    # - MathML to OMML conversion
    # - AsciiMath to OMML conversion
    # - Fallback wrapping when Plurimath is unavailable
    #
    # @example Convert MathML to OMML
    #   omml = MathConverter.mathml_to_omml("<math><mi>x</mi></math>")
    #
    # @example Convert AsciiMath to OMML
    #   omml = MathConverter.asciimath_to_omml("x^2 + y^2 = z^2")
    class MathConverter
      # Check if Plurimath gem is available.
      #
      # @return [Boolean] true if Plurimath is available
      def self.plurimath_available?
        @plurimath_available ||= begin
          require "plurimath"
          true
        rescue LoadError
          false
        end
      end

      # Convert MathML to OOXML Math (OMML).
      #
      # Uses Plurimath for conversion if available, otherwise wraps
      # the MathML in basic OMML structure.
      #
      # @param mathml_string [String] The MathML content
      # @return [String] The OMML representation
      #
      # @example Convert simple MathML
      #   omml = MathConverter.mathml_to_omml("<math><mi>x</mi></math>")
      def self.mathml_to_omml(mathml_string)
        return "" if mathml_string.nil? || mathml_string.empty?

        if plurimath_available?
          begin
            Plurimath::Math.parse(mathml_string, :mathml).to_omml
          rescue Plurimath::Math::ParseError => e
            Uniword.logger&.debug { "MathML conversion failed: #{e.message}" }
            wrap_in_omml(mathml_string)
          end
        else
          wrap_in_omml(mathml_string)
        end
      end

      # Convert AsciiMath to OOXML Math (OMML).
      #
      # Parses AsciiMath notation and converts to OMML using Plurimath.
      # Falls back to plain text if Plurimath is unavailable.
      #
      # @param asciimath_string [String] The AsciiMath content
      # @param delimiters [Array<String>] The delimiters used (default: ['$$', '$$'])
      # @return [String] The OMML representation or plain text
      #
      # @example Convert AsciiMath formula
      #   omml = MathConverter.asciimath_to_omml("x^2 + y^2 = z^2")
      def self.asciimath_to_omml(asciimath_string, _delimiters = ["$$", "$$"])
        return "" if asciimath_string.nil? || asciimath_string.empty?

        if plurimath_available?
          begin
            parsed = Plurimath::Math.parse(asciimath_string, :asciimath)
            parsed.to_omml
          rescue Plurimath::Math::ParseError => e
            Uniword.logger&.debug { "AsciiMath conversion failed: #{e.message}" }
            asciimath_string
          end
        else
          # No conversion possible without Plurimath
          asciimath_string
        end
      end

      # Wrap MathML in basic OMML structure.
      #
      # Provides minimal OMML wrapping when Plurimath is not available.
      # This allows Word to potentially recognize the math content.
      #
      # @param mathml_string [String] The MathML content
      # @return [String] The wrapped OMML
      #
      # @api private
      def self.wrap_in_omml(mathml_string)
        <<~OMML
          <m:oMathPara xmlns:m="http://schemas.microsoft.com/office/2004/12/omml">
            <m:oMath>
              <m:r>
                <m:t>#{mathml_string}</m:t>
              </m:r>
            </m:oMath>
          </m:oMathPara>
        OMML
      end

      # Detect math content in HTML element.
      #
      # Identifies math elements by tag name or special markers.
      #
      # @param element [Nokogiri::XML::Element] The HTML element
      # @return [Boolean] true if element contains math content
      #
      # @example Check if element is math
      #   is_math = MathConverter.math_element?(element)
      def self.math_element?(element)
        return false unless element.respond_to?(:name)

        math_tags = %w[math mml:math m:oMath m:oMathPara]
        return true if math_tags.include?(element.name)
        return true if element["class"]&.include?("math")
        return true if element["data-mathml"]

        false
      end

      # Extract math content from element.
      #
      # Extracts the mathematical content from various element types.
      #
      # @param element [Nokogiri::XML::Element] The HTML element
      # @return [Hash] Hash with :type and :content
      #
      # @example Extract math from element
      #   math = MathConverter.extract_math(element)
      #   # => { type: :mathml, content: "<math>...</math>" }
      def self.extract_math(element)
        if element["data-mathml"]
          { type: :mathml, content: element["data-mathml"] }
        elsif element.name =~ /^(math|mml:math)$/
          { type: :mathml, content: element.to_s }
        elsif element.name =~ /^m:(oMath|oMathPara)$/
          { type: :omml, content: element.to_s }
        elsif element["class"]&.include?("asciimath")
          { type: :asciimath, content: element.text }
        else
          { type: :unknown, content: element.to_s }
        end
      end
    end
  end
end
