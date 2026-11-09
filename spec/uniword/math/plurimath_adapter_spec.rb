# frozen_string_literal: true

require "spec_helper"

# Check if plurimath is available before requiring the adapter
begin
  require "plurimath"
  PLURIMATH_AVAILABLE = true
rescue LoadError, ArgumentError
  PLURIMATH_AVAILABLE = false
end

require "uniword/math/plurimath_adapter" if PLURIMATH_AVAILABLE
require "uniword/math_equation"

# Only run these tests if plurimath is available
if PLURIMATH_AVAILABLE
  RSpec.describe Uniword::Math::PlurimathAdapter do
    let(:omml_inline) do
      <<~XML
        <m:oMath xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math">
          <m:r><m:t>x</m:t></m:r>
        </m:oMath>
      XML
    end

    let(:omml_block) do
      <<~XML
        <m:oMathPara xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math">
          <m:oMathParaPr>
            <m:jc m:val="center"/>
          </m:oMathParaPr>
          <m:oMath>
            <m:r><m:t>x</m:t></m:r>
          </m:oMath>
        </m:oMathPara>
      XML
    end

    def with_captured_warnings
      buffer = StringIO.new
      original_logger = Uniword.logger
      Uniword.logger = Logger.new(buffer)
      yield buffer
    ensure
      Uniword.logger = original_logger
    end

    describe ".from_omml" do
      it "creates a MathEquation from OMML string" do
        result = described_class.from_omml(omml_inline)

        expect(result).to be_a(Uniword::MathEquation)
        expect(result.display_type).to eq("inline")
        expect(result.formula).to be_a(Plurimath::Math::Formula)
      end

      it "detects inline display type from m:oMath" do
        result = described_class.from_omml(omml_inline)
        expect(result.display_type).to eq("inline")
        expect(result.inline?).to be true
      end

      it "detects block display type from m:oMathPara" do
        result = described_class.from_omml(omml_block)
        expect(result.display_type).to eq("block")
        expect(result.block?).to be true
      end

      it "extracts alignment from paragraph properties" do
        result = described_class.from_omml(omml_block)
        expect(result.alignment).to eq("center")
      end

      it "raises on malformed XML" do
        expect { described_class.from_omml("not xml at all") }
          .to raise_error(Moxml::ParseError)
      end

      it "degrades unparseable math to an empty formula" do
        empty_math = '<m:oMath xmlns:m="' \
                     'http://schemas.openxmlformats.org/officeDocument/2006/math"/>'
        result = described_class.from_omml(empty_math)

        expect(result).to be_a(Uniword::MathEquation)
        expect(result.formula).to be_a(Plurimath::Math::Formula)
      end

      it "accepts Moxml::Node input" do
        node = Moxml.parse(omml_inline).root

        result = described_class.from_omml(node)
        expect(result).to be_a(Uniword::MathEquation)
      end
    end

    describe ".to_omml" do
      let(:formula) do
        Plurimath::Math.parse(omml_inline, :omml)
      end

      let(:inline_equation) do
        Uniword::MathEquation.new(formula: formula, display_type: "inline")
      end

      let(:block_equation) do
        Uniword::MathEquation.new(
          formula: formula,
          display_type: "block",
          alignment: "center",
        )
      end

      it "converts inline equation to OMML" do
        result = described_class.to_omml(inline_equation)
        expect(result).to include("x")
        expect(result).to include("oMath")
      end

      it "wraps block equation in m:oMathPara" do
        result = described_class.to_omml(block_equation)
        expect(result).to include("oMathPara")
      end

      it "includes alignment in block equations" do
        result = described_class.to_omml(block_equation)
        expect(result).to include("m:jc")
        expect(result).to include("center")
      end

      it "raises error when equation has no formula" do
        equation = Uniword::MathEquation.new
        expect do
          described_class.to_omml(equation)
        end.to raise_error(ArgumentError, /must have a formula/)
      end

      it "handles conversion errors gracefully" do
        bad_formula = Plurimath::Math::Formula.new([nil])

        with_captured_warnings do |buffer|
          equation = Uniword::MathEquation.new(formula: bad_formula)
          result = described_class.to_omml(equation)

          expect(result).to include("m:oMath")
          expect(buffer.string).to include("Failed to convert")
        end
      end

      it "supports pretty printing option" do
        result = described_class.to_omml(block_equation, pretty: true)
        expect(result).to include("\n")
      end
    end

    describe ".determine_display_type" do
      it 'returns "inline" for m:oMath node' do
        doc = Moxml.parse(
          '<m:oMath xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"/>',
        )
        result = described_class.determine_display_type(doc.root)
        expect(result).to eq("inline")
      end

      it 'returns "block" for m:oMathPara node' do
        doc = Moxml.parse(
          '<m:oMathPara xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"/>',
        )
        result = described_class.determine_display_type(doc.root)
        expect(result).to eq("block")
      end
    end

    describe ".extract_properties" do
      it "extracts alignment from oMathParaPr" do
        xml = <<~XML
          <m:oMathPara xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math">
            <m:oMathParaPr>
              <m:jc m:val="right"/>
            </m:oMathParaPr>
          </m:oMathPara>
        XML

        doc = Moxml.parse(xml)
        properties = described_class.extract_properties(doc.root)

        expect(properties[:alignment]).to eq("right")
      end

      it "detects break settings" do
        xml = <<~XML
          <m:oMath xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math">
            <m:brk/>
          </m:oMath>
        XML

        doc = Moxml.parse(xml)
        properties = described_class.extract_properties(doc.root)

        expect(properties[:break_enabled]).to be true
      end

      it "returns empty hash when no properties present" do
        xml = '<m:oMath xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"/>'

        doc = Moxml.parse(xml)
        properties = described_class.extract_properties(doc.root)

        expect(properties).to be_a(Hash)
        expect(properties[:break_enabled]).to be false
      end
    end

    describe ".normalize_alignment" do
      it 'normalizes "left" to "left"' do
        expect(described_class.normalize_alignment("left")).to eq("left")
      end

      it 'normalizes "center" to "center"' do
        expect(described_class.normalize_alignment("center")).to eq("center")
      end

      it 'normalizes "right" to "right"' do
        expect(described_class.normalize_alignment("right")).to eq("right")
      end

      it "returns nil for unknown alignment" do
        expect(described_class.normalize_alignment("invalid")).to be_nil
      end

      it "handles case insensitivity" do
        expect(described_class.normalize_alignment("LEFT")).to eq("left")
        expect(described_class.normalize_alignment("Center")).to eq("center")
      end
    end

    describe ".parse_xml_node" do
      it "returns node when given a Moxml node" do
        doc = Moxml.parse("<root/>")
        node = doc.root

        result = described_class.parse_xml_node(node)
        expect(result).to equal(node)
      end

      it "parses string to node" do
        xml = "<root/>"
        result = described_class.parse_xml_node(xml)

        expect(result.name).to eq("root")
      end

      it "raises for invalid XML string" do
        expect do
          described_class.parse_xml_node("")
        end.to raise_error(Moxml::ParseError)
      end

      it "raises error for invalid input type" do
        expect do
          described_class.parse_xml_node(123)
        end.to raise_error(ArgumentError, /Expected String or Moxml/)
      end
    end

    describe ".extract_math_node" do
      it "returns m:oMath node directly" do
        xml = '<m:oMath xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"/>'
        doc = Moxml.parse(xml)

        result = described_class.extract_math_node(doc.root)
        expect(result.name).to eq("oMath")
      end

      it "extracts m:oMath from m:oMathPara" do
        xml = <<~XML
          <m:oMathPara xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math">
            <m:oMath><m:r><m:t>x</m:t></m:r></m:oMath>
          </m:oMathPara>
        XML

        doc = Moxml.parse(xml)
        result = described_class.extract_math_node(doc.root)

        expect(result.name).to eq("oMath")
      end

      it "finds m:oMath in descendants" do
        xml = <<~XML
          <w:p xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
               xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math">
            <w:r>
              <m:oMath><m:r><m:t>x</m:t></m:r></m:oMath>
            </w:r>
          </w:p>
        XML

        doc = Moxml.parse(xml)
        result = described_class.extract_math_node(doc.root)

        expect(result.name).to eq("oMath")
      end
    end
  end
end
