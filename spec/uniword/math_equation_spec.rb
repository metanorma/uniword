# frozen_string_literal: true

require 'spec_helper'
require 'uniword/math_equation'

RSpec.describe Uniword::MathEquation do
  describe '#initialize' do
    it 'creates a new math equation' do
      equation = described_class.new
      expect(equation).to be_a(Uniword::MathEquation)
    end

    it 'accepts formula parameter' do
      formula = double('formula', to_latex: 'x^2')
      equation = described_class.new(formula: formula)
      expect(equation.formula).to eq(formula)
    end

    it 'sets display type to inline by default' do
      equation = described_class.new
      expect(equation.display_type).to eq('inline')
    end

    it 'accepts display_type parameter' do
      equation = described_class.new(display_type: 'block')
      expect(equation.display_type).to eq('block')
    end

    it 'accepts alignment parameter' do
      equation = described_class.new(alignment: 'center')
      expect(equation.alignment).to eq('center')
    end

    it 'sets break_enabled to false by default' do
      equation = described_class.new
      expect(equation.break_enabled).to eq(false)
    end
  end

  describe '#inline?' do
    it 'returns true for inline equations' do
      equation = described_class.new(display_type: 'inline')
      expect(equation.inline?).to be true
    end

    it 'returns false for block equations' do
      equation = described_class.new(display_type: 'block')
      expect(equation.inline?).to be false
    end
  end

  describe '#block?' do
    it 'returns true for block equations' do
      equation = described_class.new(display_type: 'block')
      expect(equation.block?).to be true
    end

    it 'returns false for inline equations' do
      equation = described_class.new(display_type: 'inline')
      expect(equation.block?).to be false
    end
  end

  describe '#to_latex' do
    it 'returns empty string when formula is nil' do
      equation = described_class.new
      expect(equation.to_latex).to eq('')
    end

    it 'delegates to formula.to_latex' do
      formula = double('formula', to_latex: 'x^2 + y^2 = z^2')
      equation = described_class.new(formula: formula)
      expect(equation.to_latex).to eq('x^2 + y^2 = z^2')
    end
  end

  describe '#to_mathml' do
    it 'returns empty string when formula is nil' do
      equation = described_class.new
      expect(equation.to_mathml).to eq('')
    end

    it 'delegates to formula.to_mathml' do
      formula = double('formula', to_mathml: '<math><mi>x</mi></math>')
      equation = described_class.new(formula: formula)
      expect(equation.to_mathml).to eq('<math><mi>x</mi></math>')
    end
  end

  describe '#to_asciimath' do
    it 'returns empty string when formula is nil' do
      equation = described_class.new
      expect(equation.to_asciimath).to eq('')
    end

    it 'delegates to formula.to_asciimath' do
      formula = double('formula', to_asciimath: 'x^2')
      equation = described_class.new(formula: formula)
      expect(equation.to_asciimath).to eq('x^2')
    end
  end

  describe '#valid?' do
    it 'returns true for equation without formula' do
      equation = described_class.new
      expect(equation.valid?).to be true
    end

    it 'returns true when formula responds to to_latex' do
      formula = double('formula', to_latex: 'x^2')
      equation = described_class.new(formula: formula)
      expect(equation.valid?).to be true
    end

    it 'returns false when formula does not respond to to_latex' do
      equation = described_class.new(formula: "invalid")
      expect(equation.valid?).to be false
    end
  end

  describe '#accept' do
    it 'calls visitor.visit_math_equation' do
      equation = described_class.new
      visitor = double('visitor')
      expect(visitor).to receive(:visit_math_equation).with(equation)
      equation.accept(visitor)
    end
  end

  describe '.from_omml' do
    it 'delegates to PlurimathAdapter.from_omml' do
      omml = '<m:oMath xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"/>'

      # Mock the adapter
      adapter = class_double('Uniword::Math::PlurimathAdapter')
      stub_const('Uniword::Math::PlurimathAdapter', adapter)

      expected_equation = described_class.new
      expect(adapter).to receive(:from_omml).with(omml).and_return(expected_equation)

      result = described_class.from_omml(omml)
      expect(result).to eq(expected_equation)
    end
  end

  describe '#to_omml' do
    it 'delegates to PlurimathAdapter.to_omml' do
      formula = double('formula', to_latex: 'x^2')
      equation = described_class.new(formula: formula)

      # Mock the adapter
      adapter = class_double('Uniword::Math::PlurimathAdapter')
      stub_const('Uniword::Math::PlurimathAdapter', adapter)

      expected_omml = '<m:oMath/>'
      expect(adapter).to receive(:to_omml).with(equation, {}).and_return(expected_omml)

      result = equation.to_omml
      expect(result).to eq(expected_omml)
    end

    it 'passes options to adapter' do
      formula = double('formula', to_latex: 'x^2')
      equation = described_class.new(formula: formula)

      adapter = class_double('Uniword::Math::PlurimathAdapter')
      stub_const('Uniword::Math::PlurimathAdapter', adapter)

      options = { pretty: true }
      expect(adapter).to receive(:to_omml).with(equation, options)

      equation.to_omml(options)
    end
  end
end