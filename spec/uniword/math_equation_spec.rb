# frozen_string_literal: true

require "spec_helper"
require "uniword/math_equation"
require "uniword/math/plurimath_adapter"

# A formula stand-in with fixed outputs. MathEquation's contract is to hold
# any formula-like object and delegate rendering to it; the canned outputs
# make the delegation observable without requiring Plurimath.
class CannedFormula
  def to_latex
    "x^2"
  end

  def to_mathml
    "<math><mi>x</mi></math>"
  end

  def to_asciimath
    "x^2"
  end

  def to_omml
    '<m:r><m:t>x</m:t></m:r>'
  end
end

RSpec.describe Uniword::MathEquation do
  describe "#initialize" do
    it "creates a new math equation" do
      equation = described_class.new
      expect(equation).to be_a(described_class)
    end

    it "accepts formula parameter" do
      formula = CannedFormula.new
      equation = described_class.new(formula: formula)
      expect(equation.formula).to equal(formula)
    end

    it "sets display type to inline by default" do
      equation = described_class.new
      expect(equation.display_type).to eq("inline")
    end

    it "accepts display_type parameter" do
      equation = described_class.new(display_type: "block")
      expect(equation.display_type).to eq("block")
    end

    it "accepts alignment parameter" do
      equation = described_class.new(alignment: "center")
      expect(equation.alignment).to eq("center")
    end

    it "sets break_enabled to false by default" do
      equation = described_class.new
      expect(equation.break_enabled).to be(false)
    end
  end

  describe "#inline?" do
    it "returns true for inline equations" do
      equation = described_class.new(display_type: "inline")
      expect(equation.inline?).to be true
    end

    it "returns false for block equations" do
      equation = described_class.new(display_type: "block")
      expect(equation.inline?).to be false
    end
  end

  describe "#block?" do
    it "returns true for block equations" do
      equation = described_class.new(display_type: "block")
      expect(equation.block?).to be true
    end

    it "returns false for inline equations" do
      equation = described_class.new(display_type: "inline")
      expect(equation.block?).to be false
    end
  end

  describe "#to_latex" do
    it "returns empty string when formula is nil" do
      equation = described_class.new
      expect(equation.to_latex).to eq("")
    end

    it "delegates to formula.to_latex" do
      equation = described_class.new(formula: CannedFormula.new)
      expect(equation.to_latex).to eq("x^2")
    end
  end

  describe "#to_mathml" do
    it "returns empty string when formula is nil" do
      equation = described_class.new
      expect(equation.to_mathml).to eq("")
    end

    it "delegates to formula.to_mathml" do
      equation = described_class.new(formula: CannedFormula.new)
      expect(equation.to_mathml).to eq("<math><mi>x</mi></math>")
    end
  end

  describe "#to_asciimath" do
    it "returns empty string when formula is nil" do
      equation = described_class.new
      expect(equation.to_asciimath).to eq("")
    end

    it "delegates to formula.to_asciimath" do
      equation = described_class.new(formula: CannedFormula.new)
      expect(equation.to_asciimath).to eq("x^2")
    end
  end

  describe "#valid?" do
    it "returns true for equation without formula" do
      equation = described_class.new
      expect(equation.valid?).to be true
    end

    it "returns true when formula is a Plurimath::Formula" do
      skip "Plurimath not loaded" unless defined?(Plurimath::Formula)

      formula = Plurimath::Formula.new([Plurimath::Math::Symbol.new("x")])
      equation = described_class.new(formula: formula)
      expect(equation.valid?).to be true
    end

    it "returns false when formula is not a Plurimath::Formula" do
      equation = described_class.new(formula: "invalid")
      expect(equation.valid?).to be false
    end
  end

  describe "#accept" do
    it "calls visitor.visit_math_equation" do
      equation = described_class.new
      visitor = RecordingVisitor.new

      equation.accept(visitor)
      expect(visitor.visited).to eq([[:math_equation, equation]])
    end
  end

  describe ".from_omml" do
    it "returns an inline equation built through the adapter" do
      skip "Plurimath not loaded" unless defined?(Plurimath::Math)

      omml = <<~XML
        <m:oMath xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math">
          <m:r><m:t>x</m:t></m:r>
        </m:oMath>
      XML

      result = described_class.from_omml(omml)
      expect(result).to be_a(described_class)
      expect(result.display_type).to eq("inline")
    end
  end

  describe "#to_omml" do
    it "passes inline formula content through unwrapped" do
      equation = described_class.new(formula: CannedFormula.new)
      expect(equation.to_omml).to eq("<m:r><m:t>x</m:t></m:r>")
    end

    it "wraps block equations in m:oMathPara with alignment" do
      equation = described_class.new(
        formula: CannedFormula.new,
        display_type: "block",
        alignment: "center",
      )
      result = equation.to_omml
      expect(result).to include("oMathPara")
      expect(result).to include("m:jc")
      expect(result).to include("center")
    end

    it "passes pretty printing through to the adapter" do
      equation = described_class.new(
        formula: CannedFormula.new,
        display_type: "block",
        alignment: "center",
      )
      plain = equation.to_omml
      pretty = equation.to_omml(pretty: true)
      expect(pretty).to include("\n")
      expect(pretty.length).to be >= plain.length
    end
  end
end
