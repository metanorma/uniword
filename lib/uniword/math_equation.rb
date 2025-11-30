# frozen_string_literal: true

module Uniword
  # Represents a mathematical equation in a Word document
  # Responsibility: Hold and manage Plurimath formula objects for math equations
  #
  # Office Math Markup Language (OMML) is used in OOXML documents to represent
  # mathematical equations. This class bridges between OMML and Plurimath,
  # providing a model-based approach to math equation handling.
  #
  # v4.0.0: Plurimath integration for math equation support
  #
  # @example Create a simple equation
  #   equation = Uniword::MathEquation.new
  #   equation.formula = Plurimath::Math::Formula.new([...])
  #   equation.display_type = :inline
  #
  # @example Create from OMML
  #   equation = Uniword::MathEquation.from_omml(omml_xml)
  #   puts equation.to_latex
  #
  # @see https://github.com/plurimath/plurimath Plurimath library
  # @see ISO/IEC 29500-1 Section 22.1 OMML specification
  class MathEquation < Element
    # The Plurimath formula object representing the equation
    # @return [Plurimath::Math::Formula, nil]
    attr_accessor :formula

    # Display type for the equation
    # @return [Symbol] :inline or :block
    attribute :display_type, :string, default: -> { 'inline' }

    # Alignment for block equations
    # @return [Symbol] :left, :center, or :right
    attribute :alignment, :string

    # Whether equation should break across lines
    # @return [Boolean]
    attribute :break_enabled, :boolean, default: -> { false }

    # Initialize a new MathEquation
    #
    # @param attributes [Hash] Initial attributes
    # @option attributes [Plurimath::Math::Formula] :formula The formula object
    # @option attributes [Symbol] :display_type Display mode (:inline or :block)
    # @option attributes [Symbol] :alignment Alignment for block equations
    # @option attributes [Boolean] :break_enabled Enable line breaking
    def initialize(**attributes)
      super
      @formula = attributes[:formula]
    end

    # Create a MathEquation from OMML XML
    #
    # @param omml_xml [String, Nokogiri::XML::Node] OMML XML content
    # @return [MathEquation] New equation instance
    #
    # @example
    #   xml = '<m:oMath>...</m:oMath>'
    #   equation = MathEquation.from_omml(xml)
    def self.from_omml(omml_xml)
      require_relative 'math/plurimath_adapter'
      Math::PlurimathAdapter.from_omml(omml_xml)
    end

    # Convert equation to OMML XML
    #
    # @param options [Hash] Serialization options
    # @return [String] OMML XML string
    #
    # @example
    #   equation.to_omml
    #   # => "<m:oMath>...</m:oMath>"
    def to_omml(options = {})
      require_relative 'math/plurimath_adapter'
      Math::PlurimathAdapter.to_omml(self, options)
    end

    # Convert equation to LaTeX
    #
    # @return [String] LaTeX representation
    #
    # @example
    #   equation.to_latex
    #   # => "x^2 + y^2 = z^2"
    def to_latex
      return '' unless formula

      formula.to_latex
    end

    # Convert equation to MathML
    #
    # @return [String] MathML representation
    #
    # @example
    #   equation.to_mathml
    #   # => "<math>...</math>"
    def to_mathml
      return '' unless formula

      formula.to_mathml
    end

    # Convert equation to AsciiMath
    #
    # @return [String] AsciiMath representation
    #
    # @example
    #   equation.to_asciimath
    #   # => "x^2 + y^2 = z^2"
    def to_asciimath
      return '' unless formula

      formula.to_asciimath
    end

    # Check if equation is inline (vs block/display)
    #
    # @return [Boolean]
    def inline?
      display_type.to_s == 'inline'
    end

    # Check if equation is block/display mode
    #
    # @return [Boolean]
    def block?
      display_type.to_s == 'block'
    end

    # Visitor pattern support
    #
    # @param visitor [Object] The visitor object
    # @return [Object] Result of visitor's visit operation
    def accept(visitor)
      visitor.visit_math_equation(self)
    end

    # Validate the equation
    #
    # @return [Boolean] true if valid
    def valid?
      super && formula_valid?
    end

    private

    # Check if formula is valid
    #
    # @return [Boolean]
    def formula_valid?
      # Formula can be nil for new equations
      # If present, it should be a Plurimath formula
      return true if formula.nil?

      formula.respond_to?(:to_latex)
    end
  end
end
