# frozen_string_literal: true

require "spec_helper"

# lutaml-model hands a `to:` transform the accumulating hash and discards what
# the method returns, so a writer that returns its value writes nothing. Every
# pPr writer did that, and a fully populated pPr serialized to "--- {}".
RSpec.describe Uniword::Wordprocessingml::ParagraphProperties do
  let(:ns) { 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"' }

  def parse(inner)
    described_class.from_xml("<w:pPr #{ns}>#{inner}</w:pPr>")
  end

  describe "#to_yaml" do
    it "writes every key a populated pPr sets" do
      props = parse(<<~XML)
        <w:pStyle w:val="Heading1"/>
        <w:jc w:val="center"/>
        <w:keepNext/>
        <w:keepLines/>
        <w:pageBreakBefore/>
        <w:widowControl/>
        <w:contextualSpacing/>
        <w:suppressLineNumbers/>
        <w:bidi/>
        <w:outlineLvl w:val="2"/>
      XML

      expect(YAML.safe_load(props.to_yaml)).to eq(
        "style" => "Heading1",
        "alignment" => "center",
        "keep_next" => true,
        "keep_lines" => true,
        "page_break_before" => true,
        "widow_control" => true,
        "contextual_spacing" => true,
        "suppress_line_numbers" => true,
        "bidirectional" => true,
        "outline_level" => 2,
      )
    end

    it "leaves out the keys this pPr does not set" do
      expect(YAML.safe_load(parse("<w:keepNext/>").to_yaml))
        .to eq("keep_next" => true)
    end

    # w:val="0" and w:val="off" are off. A toggle that is explicitly off has
    # to reach YAML as false, not vanish and not come back as true.
    { "0" => false, "false" => false, "off" => false,
      "1" => true, "true" => true, "on" => true }.each do |spelling, expected|
      it "writes the toggles as #{expected} for w:val=#{spelling.inspect}" do
        props = parse(<<~XML)
          <w:keepNext w:val="#{spelling}"/>
          <w:keepLines w:val="#{spelling}"/>
          <w:pageBreakBefore w:val="#{spelling}"/>
          <w:widowControl w:val="#{spelling}"/>
          <w:contextualSpacing w:val="#{spelling}"/>
          <w:suppressLineNumbers w:val="#{spelling}"/>
          <w:bidi w:val="#{spelling}"/>
        XML

        expect(YAML.safe_load(props.to_yaml).values.uniq).to eq([expected])
      end
    end
  end

  # w:suppressLineNumbers and w:bidi are ST_OnOff elements. Declared as plain
  # :boolean attributes they read "" for every spelling, so an explicitly-off
  # flag was indistinguishable from an on one, and re-serializing dropped the
  # element entirely.
  describe "#suppress_line_numbers and #bidirectional" do
    { "1" => true, "true" => true, "on" => true,
      "0" => false, "false" => false, "off" => false }.each do |spelling, expected|
      it "reads w:val=#{spelling.inspect} as #{expected}" do
        props = parse(<<~XML)
          <w:suppressLineNumbers w:val="#{spelling}"/>
          <w:bidi w:val="#{spelling}"/>
        XML

        aggregate_failures do
          expect(props.suppress_line_numbers).to be(expected)
          expect(props.bidirectional).to be(expected)
        end
      end
    end

    it "reads a bare element as on" do
      props = parse("<w:suppressLineNumbers/><w:bidi/>")

      aggregate_failures do
        expect(props.suppress_line_numbers).to be(true)
        expect(props.bidirectional).to be(true)
      end
    end

    it "reads an absent element as off" do
      props = parse("")

      aggregate_failures do
        expect(props.suppress_line_numbers).to be(false)
        expect(props.bidirectional).to be(false)
      end
    end

    it "keeps the elements over a serialize cycle" do
      props = parse(%(<w:suppressLineNumbers w:val="0"/><w:bidi/>))
      reparsed = described_class.from_xml(props.to_xml)

      aggregate_failures do
        expect(reparsed.suppress_line_numbers).to be(false)
        expect(reparsed.bidirectional).to be(true)
        expect(props.to_xml).to include("suppressLineNumbers")
        expect(props.to_xml).to include("bidi")
      end
    end

    it "writes a w:val attribute rather than element text" do
      props = described_class.new(suppress_line_numbers: false, bidirectional: false)

      aggregate_failures do
        expect(props.to_xml).to match(%r{<(w:)?suppressLineNumbers w:val="false"\s*/>})
        expect(props.to_xml).to match(%r{<(w:)?bidi w:val="false"\s*/>})
      end
    end
  end
end
