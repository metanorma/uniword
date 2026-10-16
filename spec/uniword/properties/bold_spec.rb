# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Bold boolean elements" do
  let(:ns) { "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
  let(:ns_decl) { %(xmlns:w="#{ns}") }

  describe Uniword::Properties::Bold do
    it "serializes true as <w:b/> without val attribute" do
      bold = described_class.new
      bold.val = true
      expect(bold.to_xml).not_to include("w:val")
      expect(bold.to_xml).to include("<b ")
    end

    it "serializes false as <w:b w:val='false'/>" do
      bold = described_class.new
      bold.val = false
      expect(bold.to_xml).to include('w:val="false"')
    end

    it "parses <w:b/> as true" do
      xml = "<w:b #{ns_decl}/>"
      bold = described_class.from_xml(xml)
      expect(bold.value).to be true
    end

    it "parses <w:b w:val='false'/> as false" do
      xml = "<w:b #{ns_decl} w:val=\"false\"/>"
      bold = described_class.from_xml(xml)
      expect(bold.value).to be false
    end

    it "round-trips true through parse/serialize" do
      xml = "<w:b #{ns_decl}/>"
      bold = described_class.from_xml(xml)
      expect(bold.to_xml).not_to include("w:val")
    end

    it "round-trips false through parse/serialize" do
      xml = "<w:b #{ns_decl} w:val=\"false\"/>"
      bold = described_class.from_xml(xml)
      expect(bold.to_xml).to include('w:val="false"')
    end

    # ST_OnOff (ECMA-376) accepts 0/1, false/true and off/on. An absent w:val
    # means the toggle is on. Bold stands in for every BooleanElement
    # includer; this is the one home for that table.
    describe "#on?" do
      {
        nil => true,
        "0" => false,
        "false" => false,
        "off" => false,
        "1" => true,
        "true" => true,
        "on" => true,
      }.each do |val, expected|
        it "reads #{val.inspect} as #{expected}" do
          attr = val.nil? ? "" : %( w:val="#{val}")
          bold = described_class.from_xml("<w:b #{ns_decl}#{attr}/>")

          expect(bold.on?).to be(expected)
        end
      end

      # Unknown tokens stay on, matching the #value beside it. Reading is
      # total: a malformed attribute must not raise out of a reader.
      it "reads an unknown token as on" do
        bold = described_class.from_xml(%(<w:b #{ns_decl} w:val="garbage"/>))

        expect(bold.on?).to be(true)
      end
    end
  end

  describe Uniword::Properties::BoldCs do
    it "serializes true as <w:bCs/> without val attribute" do
      bold = described_class.new
      bold.val = true
      expect(bold.to_xml).not_to include("w:val")
      expect(bold.to_xml).to include("<bCs ")
    end

    it "serializes false as <w:bCs w:val='false'/>" do
      bold = described_class.new
      bold.val = false
      expect(bold.to_xml).to include('w:val="false"')
    end

    it "parses <w:bCs/> as true" do
      xml = "<w:bCs #{ns_decl}/>"
      bold = described_class.from_xml(xml)
      expect(bold.value).to be true
    end

    it "parses <w:bCs w:val='false'/> as false" do
      xml = "<w:bCs #{ns_decl} w:val=\"false\"/>"
      bold = described_class.from_xml(xml)
      expect(bold.value).to be false
    end

    it "round-trips true through parse/serialize" do
      xml = "<w:bCs #{ns_decl}/>"
      bold = described_class.from_xml(xml)
      expect(bold.to_xml).not_to include("w:val")
    end

    it "round-trips false through parse/serialize" do
      xml = "<w:bCs #{ns_decl} w:val=\"false\"/>"
      bold = described_class.from_xml(xml)
      expect(bold.to_xml).to include('w:val="false"')
    end
  end
end
