# frozen_string_literal: true

require 'spec_helper'
require 'uniword/mhtml/math_converter'

RSpec.describe Uniword::Mhtml::MathConverter do
  describe '.plurimath_available?' do
    it 'checks if Plurimath is available' do
      result = described_class.plurimath_available?
      expect([true, false]).to include(result)
    end
  end

  describe '.mathml_to_omml' do
    context 'with nil input' do
      it 'returns empty string' do
        expect(described_class.mathml_to_omml(nil)).to eq('')
      end
    end

    context 'with empty string' do
      it 'returns empty string' do
        expect(described_class.mathml_to_omml('')).to eq('')
      end
    end

    context 'with valid MathML' do
      let(:mathml) { '<math><mi>x</mi></math>' }

      it 'converts to OMML format' do
        result = described_class.mathml_to_omml(mathml)
        expect(result).to be_a(String)
        expect(result).not_to be_empty
      end

      it 'wraps in OMML structure when Plurimath unavailable' do
        allow(described_class).to receive(:plurimath_available?).and_return(false)
        result = described_class.mathml_to_omml(mathml)
        expect(result).to include('m:oMathPara')
        expect(result).to include('m:oMath')
        expect(result).to include(mathml)
      end
    end

    context 'with complex MathML' do
      let(:mathml) { '<math><mfrac><mi>a</mi><mi>b</mi></mfrac></math>' }

      it 'converts complex expressions' do
        result = described_class.mathml_to_omml(mathml)
        expect(result).to be_a(String)
        expect(result).not_to be_empty
      end
    end
  end

  describe '.asciimath_to_omml' do
    context 'with nil input' do
      it 'returns empty string' do
        expect(described_class.asciimath_to_omml(nil)).to eq('')
      end
    end

    context 'with empty string' do
      it 'returns empty string' do
        expect(described_class.asciimath_to_omml('')).to eq('')
      end
    end

    context 'with valid AsciiMath' do
      let(:asciimath) { 'x^2 + y^2 = z^2' }

      it 'converts to OMML format when Plurimath available' do
        if described_class.plurimath_available?
          result = described_class.asciimath_to_omml(asciimath)
          expect(result).to be_a(String)
          expect(result).not_to be_empty
        else
          result = described_class.asciimath_to_omml(asciimath)
          expect(result).to eq(asciimath)
        end
      end

      it 'returns plain text when Plurimath unavailable' do
        allow(described_class).to receive(:plurimath_available?).and_return(false)
        result = described_class.asciimath_to_omml(asciimath)
        expect(result).to eq(asciimath)
      end
    end

    context 'with custom delimiters' do
      let(:asciimath) { 'sqrt(x)' }

      it 'accepts delimiter parameter' do
        result = described_class.asciimath_to_omml(asciimath, ['$', '$'])
        expect(result).to be_a(String)
      end
    end
  end

  describe '.wrap_in_omml' do
    let(:mathml) { '<math><mi>x</mi></math>' }

    it 'wraps content in OMML structure' do
      result = described_class.wrap_in_omml(mathml)
      expect(result).to include('m:oMathPara')
      expect(result).to include('m:oMath')
      expect(result).to include('m:r')
      expect(result).to include('m:t')
      expect(result).to include(mathml)
    end

    it 'includes proper namespace' do
      result = described_class.wrap_in_omml(mathml)
      expect(result).to include('xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"')
    end
  end

  describe '.math_element?' do
    context 'with math element' do
      it 'detects math tag' do
        element = double('element', name: 'math')
        allow(element).to receive(:respond_to?).with(:name).and_return(true)
        allow(element).to receive(:[]).with('class').and_return(nil)
        allow(element).to receive(:[]).with('data-mathml').and_return(nil)

        expect(described_class.math_element?(element)).to be true
      end

      it 'detects mml:math tag' do
        element = double('element', name: 'mml:math')
        allow(element).to receive(:respond_to?).with(:name).and_return(true)
        allow(element).to receive(:[]).with('class').and_return(nil)
        allow(element).to receive(:[]).with('data-mathml').and_return(nil)

        expect(described_class.math_element?(element)).to be true
      end

      it 'detects m:oMath tag' do
        element = double('element', name: 'm:oMath')
        allow(element).to receive(:respond_to?).with(:name).and_return(true)
        allow(element).to receive(:[]).with('class').and_return(nil)
        allow(element).to receive(:[]).with('data-mathml').and_return(nil)

        expect(described_class.math_element?(element)).to be true
      end

      it 'detects math class' do
        element = double('element', name: 'div')
        allow(element).to receive(:respond_to?).with(:name).and_return(true)
        allow(element).to receive(:[]).with('class').and_return('math')
        allow(element).to receive(:[]).with('data-mathml').and_return(nil)

        expect(described_class.math_element?(element)).to be true
      end

      it 'detects data-mathml attribute' do
        element = double('element', name: 'span')
        allow(element).to receive(:respond_to?).with(:name).and_return(true)
        allow(element).to receive(:[]) do |arg|
          case arg
          when 'class' then nil
          when 'data-mathml' then '<math><mi>x</mi></math>'
          end
        end

        expect(described_class.math_element?(element)).to be true
      end
    end

    context 'with non-math element' do
      it 'returns false for paragraph' do
        element = double('element', name: 'p')
        allow(element).to receive(:respond_to?).with(:name).and_return(true)
        allow(element).to receive(:[]) do |arg|
          nil
        end

        expect(described_class.math_element?(element)).to be false
      end

      it 'returns false for nil' do
        expect(described_class.math_element?(nil)).to be false
      end
    end
  end

  describe '.extract_math' do
    context 'with data-mathml attribute' do
      it 'extracts MathML from attribute' do
        mathml = '<math><mi>x</mi></math>'
        element = double('element')
        allow(element).to receive(:[]).with('data-mathml').and_return(mathml)

        result = described_class.extract_math(element)
        expect(result[:type]).to eq(:mathml)
        expect(result[:content]).to eq(mathml)
      end
    end

    context 'with math tag' do
      it 'extracts MathML from element' do
        element = double('element', name: 'math')
        allow(element).to receive(:[]).with('data-mathml').and_return(nil)
        allow(element).to receive(:to_s).and_return('<math><mi>x</mi></math>')

        result = described_class.extract_math(element)
        expect(result[:type]).to eq(:mathml)
        expect(result[:content]).to eq('<math><mi>x</mi></math>')
      end
    end

    context 'with m:oMath tag' do
      it 'extracts OMML from element' do
        element = double('element', name: 'm:oMath')
        allow(element).to receive(:[]).with('data-mathml').and_return(nil)
        allow(element).to receive(:to_s).and_return('<m:oMath>...</m:oMath>')

        result = described_class.extract_math(element)
        expect(result[:type]).to eq(:omml)
        expect(result[:content]).to eq('<m:oMath>...</m:oMath>')
      end
    end

    context 'with asciimath class' do
      it 'extracts AsciiMath from text' do
        element = double('element')
        allow(element).to receive(:[]).with('data-mathml').and_return(nil)
        allow(element).to receive(:name).and_return('span')
        allow(element).to receive(:[]).with('class').and_return('asciimath')
        allow(element).to receive(:text).and_return('x^2 + y^2')

        result = described_class.extract_math(element)
        expect(result[:type]).to eq(:asciimath)
        expect(result[:content]).to eq('x^2 + y^2')
      end
    end

    context 'with unknown math content' do
      it 'returns unknown type' do
        element = double('element', name: 'div')
        allow(element).to receive(:[]).with('data-mathml').and_return(nil)
        allow(element).to receive(:[]).with('class').and_return(nil)
        allow(element).to receive(:to_s).and_return('<div>content</div>')

        result = described_class.extract_math(element)
        expect(result[:type]).to eq(:unknown)
        expect(result[:content]).to eq('<div>content</div>')
      end
    end
  end
end