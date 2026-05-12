# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Italic boolean elements" do
  let(:ns) { "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }
  let(:ns_decl) { %(xmlns:w="#{ns}") }

  describe Uniword::Properties::Italic do
    it "serializes true as <w:i/> without val attribute" do
      italic = described_class.new
      italic.val = true
      expect(italic.to_xml).not_to include("w:val")
      expect(italic.to_xml).to include("<i ")
    end

    it "serializes false as <w:i w:val='false'/>" do
      italic = described_class.new
      italic.val = false
      expect(italic.to_xml).to include('w:val="false"')
    end

    it "parses <w:i/> as true" do
      xml = "<w:i #{ns_decl}/>"
      italic = described_class.from_xml(xml)
      expect(italic.value).to be true
    end

    it "parses <w:i w:val='false'/> as false" do
      xml = "<w:i #{ns_decl} w:val=\"false\"/>"
      italic = described_class.from_xml(xml)
      expect(italic.value).to be false
    end

    it "round-trips true through parse/serialize" do
      xml = "<w:i #{ns_decl}/>"
      italic = described_class.from_xml(xml)
      expect(italic.to_xml).not_to include("w:val")
    end

    it "round-trips false through parse/serialize" do
      xml = "<w:i #{ns_decl} w:val=\"false\"/>"
      italic = described_class.from_xml(xml)
      expect(italic.to_xml).to include('w:val="false"')
    end
  end

  describe Uniword::Properties::ItalicCs do
    it "serializes true as <w:iCs/> without val attribute" do
      italic = described_class.new
      italic.val = true
      expect(italic.to_xml).not_to include("w:val")
      expect(italic.to_xml).to include("<iCs ")
    end

    it "serializes false as <w:iCs w:val='false'/>" do
      italic = described_class.new
      italic.val = false
      expect(italic.to_xml).to include('w:val="false"')
    end

    it "parses <w:iCs/> as true" do
      xml = "<w:iCs #{ns_decl}/>"
      italic = described_class.from_xml(xml)
      expect(italic.value).to be true
    end

    it "parses <w:iCs w:val='false'/> as false" do
      xml = "<w:iCs #{ns_decl} w:val=\"false\"/>"
      italic = described_class.from_xml(xml)
      expect(italic.value).to be false
    end

    it "round-trips true through parse/serialize" do
      xml = "<w:iCs #{ns_decl}/>"
      italic = described_class.from_xml(xml)
      expect(italic.to_xml).not_to include("w:val")
    end

    it "round-trips false through parse/serialize" do
      xml = "<w:iCs #{ns_decl} w:val=\"false\"/>"
      italic = described_class.from_xml(xml)
      expect(italic.to_xml).to include('w:val="false"')
    end
  end
end
