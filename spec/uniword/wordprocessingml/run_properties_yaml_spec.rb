# frozen_string_literal: true

require "spec_helper"

# lutaml-model hands a custom `to:` method the accumulating hash and drops
# its return value, so RunProperties#to_yaml used to emit "--- {}" for a
# fully populated rPr and StyleSet exports silently lost every run property.
RSpec.describe Uniword::Wordprocessingml::RunProperties do
  ns = 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'

  let(:rpr) do
    described_class.from_xml(<<~XML)
      <w:rPr #{ns}>
        <w:b/>
        <w:i w:val="0"/>
        <w:caps/>
        <w:sz w:val="24"/>
        <w:color w:val="FF0000"/>
        <w:rFonts w:ascii="Arial"/>
      </w:rPr>
    XML
  end

  describe "#to_yaml" do
    it "emits the properties the rPr actually carries" do
      expect(YAML.safe_load(rpr.to_yaml)).to eq(
        "bold" => true,
        "italic" => false,
        "caps" => true,
        "size" => 24,
        "color" => "FF0000",
        "font" => "Arial",
      )
    end

    it "leaves out properties the rPr does not set" do
      minimal = described_class.from_xml(%(<w:rPr #{ns}><w:b/></w:rPr>))
      expect(YAML.safe_load(minimal.to_yaml)).to eq("bold" => true)
    end

    # A w:val of "0" is off. Emitting it as true was the same defect the
    # XML readers had.
    it "writes an off toggle as false, not true" do
      off = described_class.from_xml(%(<w:rPr #{ns}><w:b w:val="off"/></w:rPr>))
      expect(YAML.safe_load(off.to_yaml)).to eq("bold" => false)
    end
  end

  describe "#from_yaml" do
    it "builds an off toggle from a false value" do
      loaded = described_class.from_yaml("bold: false\n")

      aggregate_failures do
        expect(loaded.bold?).to be(false)
        expect(loaded.to_xml).to include('w:val="false"')
      end
    end

    it "builds an off toggle from the string \"0\"" do
      expect(described_class.from_yaml("bold: \"0\"\n").bold?).to be(false)
    end
  end

  describe "a YAML round trip" do
    it "preserves every property it wrote" do
      round_tripped = described_class.from_yaml(rpr.to_yaml)

      aggregate_failures do
        expect(round_tripped.bold?).to be(true)
        expect(round_tripped.italic?).to be(false)
        expect(round_tripped.caps?).to be(true)
        expect(round_tripped.size.value).to eq(24)
        expect(round_tripped.color.value).to eq("FF0000")
        expect(round_tripped.font).to eq("Arial")
      end
    end
  end
end
