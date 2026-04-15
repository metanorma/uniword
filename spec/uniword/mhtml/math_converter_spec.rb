# frozen_string_literal: true

require "spec_helper"
require "uniword/mhtml/math_converter"
require "nokogiri"

RSpec.describe Uniword::Mhtml::MathConverter do
  describe ".plurimath_available?" do
    it "checks if Plurimath is available" do
      result = described_class.plurimath_available?
      expect([true, false]).to include(result)
    end
  end

  describe ".mathml_to_omml" do
    context "with nil input" do
      it "returns empty string" do
        expect(described_class.mathml_to_omml(nil)).to eq("")
      end
    end

    context "with empty string" do
      it "returns empty string" do
        expect(described_class.mathml_to_omml("")).to eq("")
      end
    end

    context "with valid MathML" do
      let(:mathml) { "<math><mi>x</mi></math>" }

      it "converts to OMML format" do
        result = described_class.mathml_to_omml(mathml)
        expect(result).to be_a(String)
        expect(result).not_to be_empty
      end

      it "produces valid XML output" do
        result = described_class.mathml_to_omml(mathml)
        # Should be parseable as XML
        doc = Nokogiri::XML(result)
        expect(doc.errors).to be_empty
      end
    end

    context "with complex MathML" do
      let(:mathml) { "<math><mfrac><mi>a</mi><mi>b</mi></mfrac></math>" }

      it "converts complex expressions" do
        result = described_class.mathml_to_omml(mathml)
        expect(result).to be_a(String)
        expect(result).not_to be_empty
      end
    end
  end

  describe ".asciimath_to_omml" do
    context "with nil input" do
      it "returns empty string" do
        expect(described_class.asciimath_to_omml(nil)).to eq("")
      end
    end

    context "with empty string" do
      it "returns empty string" do
        expect(described_class.asciimath_to_omml("")).to eq("")
      end
    end

    context "with valid AsciiMath" do
      let(:asciimath) { "x^2 + y^2 = z^2" }

      it "converts to OMML format when Plurimath available" do
        result = described_class.asciimath_to_omml(asciimath)
        if described_class.plurimath_available?
          expect(result).to be_a(String)
          expect(result).not_to be_empty
        else
          expect(result).to eq(asciimath)
        end
      end
    end

    context "with custom delimiters" do
      let(:asciimath) { "sqrt(x)" }

      it "accepts delimiter parameter" do
        result = described_class.asciimath_to_omml(asciimath, ["$", "$"])
        expect(result).to be_a(String)
      end
    end
  end

  describe ".wrap_in_omml" do
    let(:mathml) { "<math><mi>x</mi></math>" }

    it "wraps content in OMML structure" do
      result = described_class.wrap_in_omml(mathml)
      expect(result).to include("m:oMathPara")
      expect(result).to include("m:oMath")
      expect(result).to include("m:r")
      expect(result).to include("m:t")
      expect(result).to include(mathml)
    end

    it "includes proper namespace" do
      result = described_class.wrap_in_omml(mathml)
      expect(result).to include('xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"')
    end
  end

  describe ".math_element?" do
    context "with math element" do
      it "detects math tag" do
        doc = Nokogiri::HTML("<math><mi>x</mi></math>")
        element = doc.at("math")

        expect(described_class.math_element?(element)).to be true
      end

      it "detects mml:math tag" do
        doc = Nokogiri::XML('<mml:math xmlns:mml="http://www.w3.org/1998/Math/MathML"><mml:mi>x</mml:mi></mml:math>')
        element = doc.at_xpath("//mml:math")

        expect(described_class.math_element?(element)).to be true if element
      end

      it "detects math class" do
        doc = Nokogiri::HTML('<div class="math">x</div>')
        element = doc.at("div.math")

        expect(described_class.math_element?(element)).to be true
      end

      it "detects data-mathml attribute" do
        doc = Nokogiri::HTML('<span data-mathml="<math><mi>x</mi></math>">x</span>')
        element = doc.at("span")

        expect(described_class.math_element?(element)).to be true
      end
    end

    context "with non-math element" do
      it "returns false for paragraph" do
        doc = Nokogiri::HTML("<p>text</p>")
        element = doc.at("p")

        expect(described_class.math_element?(element)).to be false
      end

      it "returns false for nil" do
        expect(described_class.math_element?(nil)).to be false
      end
    end
  end

  describe ".extract_math" do
    context "with data-mathml attribute" do
      it "extracts MathML from attribute" do
        mathml = "<math><mi>x</mi></math>"
        doc = Nokogiri::HTML("<span data-mathml=\"#{mathml}\">x</span>")
        element = doc.at("span")

        result = described_class.extract_math(element)
        expect(result[:type]).to eq(:mathml)
        expect(result[:content]).to eq(mathml)
      end
    end

    context "with math tag" do
      it "extracts MathML from element" do
        doc = Nokogiri::HTML("<math><mi>x</mi></math>")
        element = doc.at("math")

        result = described_class.extract_math(element)
        expect(result[:type]).to eq(:mathml)
        expect(result[:content]).to include("<math")
        expect(result[:content]).to include("<mi>x</mi>")
      end
    end

    context "with asciimath class" do
      it "extracts AsciiMath from text" do
        doc = Nokogiri::HTML('<span class="asciimath">x^2 + y^2</span>')
        element = doc.at("span.asciimath")

        result = described_class.extract_math(element)
        expect(result[:type]).to eq(:asciimath)
        expect(result[:content]).to eq("x^2 + y^2")
      end
    end

    context "with unknown math content" do
      it "returns unknown type for non-math element" do
        doc = Nokogiri::HTML("<div>content</div>")
        element = doc.at("div")

        result = described_class.extract_math(element)
        expect(result[:type]).to eq(:unknown)
        expect(result[:content]).to include("content")
      end
    end
  end
end
