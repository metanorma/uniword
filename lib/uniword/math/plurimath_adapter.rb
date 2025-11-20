# frozen_string_literal: true

require 'plurimath'

module Uniword
  module Math
    # Adapter for Plurimath library integration
    # Responsibility: Convert between OMML and Plurimath formula objects
    #
    # This adapter provides bidirectional conversion between:
    # - OMML (Office Math Markup Language) used in OOXML
    # - Plurimath's internal formula representation
    #
    # The adapter handles:
    # - Parsing OMML XML to Plurimath formulas
    # - Serializing Plurimath formulas to OMML XML
    # - Converting between display types (inline vs block)
    # - Preserving equation properties and formatting
    #
    # v4.0.0: Initial implementation for math equation support
    #
    # @example Convert OMML to Plurimath
    #   omml = '<m:oMath>...</m:oMath>'
    #   equation = PlurimathAdapter.from_omml(omml)
    #   puts equation.to_latex
    #
    # @example Convert Plurimath to OMML
    #   equation = MathEquation.new(formula: formula)
    #   omml = PlurimathAdapter.to_omml(equation)
    #
    # @see https://github.com/plurimath/plurimath Plurimath library
    # @see ISO/IEC 29500-1 Section 22.1 OMML specification
    class PlurimathAdapter
      # OMML namespace URI
      OMML_NAMESPACE = "http://schemas.openxmlformats.org/officeDocument/2006/math"

      # Create a MathEquation from OMML XML
      #
      # @param omml_xml [String, Nokogiri::XML::Node] OMML XML content
      # @return [MathEquation] New equation instance with parsed formula
      #
      # @example Parse OMML
      #   xml = '<m:oMath xmlns:m="..."><m:r><m:t>x</m:t></m:r></m:oMath>'
      #   equation = PlurimathAdapter.from_omml(xml)
      #
      # @raise [ArgumentError] if XML is invalid or cannot be parsed
      def self.from_omml(omml_xml)
        node = parse_xml_node(omml_xml)

        # Determine if this is an inline or block equation
        display_type = determine_display_type(node)

        # Extract equation properties
        properties = extract_properties(node)

        # Convert OMML to Plurimath formula using Plurimath's OMML parser
        formula = parse_omml_to_formula(node)

        # Create and return MathEquation
        MathEquation.new(
          formula: formula,
          display_type: display_type,
          alignment: properties[:alignment],
          break_enabled: properties[:break_enabled]
        )
      end

      # Convert a MathEquation to OMML XML
      #
      # @param equation [MathEquation] The equation to convert
      # @param options [Hash] Serialization options
      # @option options [Boolean] :pretty (false) Pretty print XML
      # @return [String] OMML XML string
      #
      # @example Convert to OMML
      #   equation = MathEquation.new(formula: formula)
      #   omml = PlurimathAdapter.to_omml(equation)
      #
      # @raise [ArgumentError] if equation has no formula
      def self.to_omml(equation, options = {})
        raise ArgumentError, "Equation must have a formula" unless equation.formula

        # Convert Plurimath formula to OMML using Plurimath's OMML serializer
        omml_content = formula_to_omml(equation.formula)

        # Wrap in appropriate container based on display type
        wrapped = wrap_omml(omml_content, equation, options)

        # Format output
        format_omml(wrapped, options)
      end

      # Parse OMML to Plurimath formula
      #
      # @param node [Nokogiri::XML::Node] OMML node
      # @return [Plurimath::Math::Formula] Parsed formula
      #
      # @api private
      def self.parse_omml_to_formula(node)
        # Extract the math content (m:oMath or m:oMathPara)
        math_node = extract_math_node(node)

        # Use Plurimath's OMML parser
        # Plurimath.parse expects OMML string
        omml_string = math_node.to_xml

        Plurimath::Math.parse(omml_string, :omml)
      rescue StandardError => e
        # If Plurimath parsing fails, create an empty formula
        # This allows graceful degradation
        Uniword::Logger.warn("Failed to parse OMML: #{e.message}")
        Plurimath::Math::Formula.new([])
      end

      # Convert Plurimath formula to OMML
      #
      # @param formula [Plurimath::Math::Formula] The formula to convert
      # @return [String] OMML XML content
      #
      # @api private
      def self.formula_to_omml(formula)
        # Use Plurimath's OMML serializer
        formula.to_omml
      rescue StandardError => e
        Uniword::Logger.warn("Failed to convert formula to OMML: #{e.message}")
        # Return minimal valid OMML
        '<m:oMath xmlns:m="' + OMML_NAMESPACE + '"/>'
      end

      # Determine if equation is inline or block display
      #
      # @param node [Nokogiri::XML::Node] OMML node
      # @return [String] "inline" or "block"
      #
      # @api private
      def self.determine_display_type(node)
        # m:oMathPara indicates block/display mode
        # m:oMath alone indicates inline mode
        node.name == "oMathPara" ? "block" : "inline"
      end

      # Extract equation properties from OMML
      #
      # @param node [Nokogiri::XML::Node] OMML node
      # @return [Hash] Extracted properties
      #
      # @api private
      def self.extract_properties(node)
        properties = {}

        # Check for paragraph properties if this is oMathPara
        if node.name == "oMathPara"
          para_props = node.at_xpath(".//m:oMathParaPr", "m" => OMML_NAMESPACE)

          if para_props
            # Extract alignment (m:jc)
            jc_node = para_props.at_xpath(".//m:jc", "m" => OMML_NAMESPACE)
            if jc_node
              jc_val = jc_node.attr("m:val")
              properties[:alignment] = normalize_alignment(jc_val)
            end
          end
        end

        # Check for break settings (m:brk)
        brk_node = node.at_xpath(".//m:brk", "m" => OMML_NAMESPACE)
        properties[:break_enabled] = !brk_node.nil?

        properties
      end

      # Normalize OMML alignment value to symbol
      #
      # @param omml_alignment [String] OMML alignment value
      # @return [String, nil] Normalized alignment
      #
      # @api private
      def self.normalize_alignment(omml_alignment)
        case omml_alignment&.downcase
        when "left" then "left"
        when "center" then "center"
        when "right" then "right"
        else nil
        end
      end

      # Wrap OMML content in appropriate container
      #
      # @param omml_content [String] OMML math content
      # @param equation [MathEquation] The equation
      # @param options [Hash] Options
      # @return [String] Wrapped OMML
      #
      # @api private
      def self.wrap_omml(omml_content, equation, options = {})
        if equation.block?
          wrap_block_equation(omml_content, equation)
        else
          wrap_inline_equation(omml_content)
        end
      end

      # Wrap inline equation
      #
      # @param omml_content [String] OMML math content
      # @return [String] Wrapped OMML
      #
      # @api private
      def self.wrap_inline_equation(omml_content)
        # Inline equations are just m:oMath
        omml_content
      end

      # Wrap block equation with paragraph properties
      #
      # @param omml_content [String] OMML math content
      # @param equation [MathEquation] The equation
      # @return [String] Wrapped OMML
      #
      # @api private
      def self.wrap_block_equation(omml_content, equation)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml['m'].oMathPara('xmlns:m' => OMML_NAMESPACE) do
            # Add paragraph properties if needed
            if equation.alignment || equation.break_enabled
              xml['m'].oMathParaPr do
                if equation.alignment
                  xml['m'].jc('m:val' => equation.alignment)
                end
              end
            end

            # Add the math content
            xml.parent << Nokogiri::XML.fragment(omml_content)
          end
        end

        builder.to_xml
      end

      # Format OMML output
      #
      # @param omml [String] OMML XML
      # @param options [Hash] Format options
      # @option options [Boolean] :pretty Pretty print
      # @return [String] Formatted OMML
      #
      # @api private
      def self.format_omml(omml, options = {})
        return omml unless options[:pretty]

        doc = Nokogiri::XML(omml)
        doc.to_xml(indent: 2)
      end

      # Parse XML node from string or node
      #
      # @param xml [String, Nokogiri::XML::Node] XML input
      # @return [Nokogiri::XML::Node] Parsed node
      #
      # @api private
      def self.parse_xml_node(xml)
        case xml
        when Nokogiri::XML::Node
          xml
        when String
          doc = Nokogiri::XML(xml)
          doc.root || raise(ArgumentError, "Invalid XML: no root element")
        else
          raise ArgumentError, "Expected String or Nokogiri::XML::Node, got #{xml.class}"
        end
      end

      # Extract the math node (m:oMath) from container
      #
      # @param node [Nokogiri::XML::Node] OMML node (could be oMath or oMathPara)
      # @return [Nokogiri::XML::Node] The m:oMath node
      #
      # @api private
      def self.extract_math_node(node)
        if node.name == "oMath"
          node
        elsif node.name == "oMathPara"
          # Extract m:oMath from m:oMathPara
          node.at_xpath(".//m:oMath", "m" => OMML_NAMESPACE) || node
        else
          # Try to find m:oMath descendant
          node.at_xpath(".//m:oMath", "m" => OMML_NAMESPACE) || node
        end
      end
    end
  end
end