# frozen_string_literal: true

require "spec_helper"
require "canon/rspec_matchers"

RSpec.describe "Complete DOCX Round-Trip Fidelity" do
  COMPLETE_TEST_DOC = "spec/fixtures/uniword-demo/demo_formal_integral_proper.docx"
  COMPLETE_OUTPUT = "test_output/complete_roundtrip.docx"

  # List of all XML files to test (13 files total for Week 1 goal)
  XML_FILES = [
    "[Content_Types].xml",
    "_rels/.rels",
    "docProps/core.xml",
    "docProps/app.xml",
    "word/document.xml",
    "word/styles.xml",
    "word/fontTable.xml",
    "word/settings.xml",
    "word/webSettings.xml",
    "word/numbering.xml",
    "word/_rels/document.xml.rels",
    "word/theme/theme1.xml",
    "word/theme/_rels/theme1.xml.rels",
  ].freeze

  before(:all) do
    # Load and save document once for all tests
    package = Uniword::Docx::Package.from_file(COMPLETE_TEST_DOC)
    package.to_file(COMPLETE_OUTPUT)
  end

  def self.extract_file(docx_path, file_path)
    require "zip"
    Zip::File.open(docx_path) do |zip|
      entry = zip.find_entry(file_path)
      return entry&.get_input_stream&.read
    end
  end

  # Normalize XML for comparison
  def self.normalize_xml(xml)
    XmlNormalizers.normalize_for_roundtrip(xml)
  end

  def normalize_xml(xml)
    XmlNormalizers.normalize_for_roundtrip(xml)
  end

  def self.extract_rel_targets(xml)
    return [] if xml.nil?

    xml.scan(/Target="([^"]+)"/).flatten
  end

  # Create individual test for each XML file
  describe "[Content_Types].xml" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC, "[Content_Types].xml")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT, "[Content_Types].xml")

      expect(normalize_xml(roundtrip)).to be_xml_equivalent_to(normalize_xml(original))
    end
  end

  describe "_rels/.rels" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC, "_rels/.rels")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT, "_rels/.rels")

      expect(normalize_xml(roundtrip)).to be_xml_equivalent_to(normalize_xml(original))
    end
  end

  describe "docProps/core.xml" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC, "docProps/core.xml")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT, "docProps/core.xml")

      expect(normalize_xml(roundtrip)).to be_xml_equivalent_to(normalize_xml(original))
    end
  end

  describe "docProps/app.xml" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC, "docProps/app.xml")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT, "docProps/app.xml")

      expect(normalize_xml(roundtrip)).to be_xml_equivalent_to(normalize_xml(original))
    end
  end

  describe "word/document.xml" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC, "word/document.xml")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT, "word/document.xml")

      expect(normalize_xml(roundtrip)).to be_xml_equivalent_to(normalize_xml(original))
    end
  end

  describe "word/styles.xml" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC, "word/styles.xml")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT, "word/styles.xml")

      expect(normalize_xml(roundtrip)).to be_xml_equivalent_to(normalize_xml(original))
    end
  end

  describe "word/fontTable.xml" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC, "word/fontTable.xml")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT, "word/fontTable.xml")

      expect(normalize_xml(roundtrip)).to be_xml_equivalent_to(normalize_xml(original))
    end
  end

  describe "word/settings.xml" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC, "word/settings.xml")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT, "word/settings.xml")

      expect(normalize_xml(roundtrip)).to be_xml_equivalent_to(normalize_xml(original))
    end
  end

  describe "word/webSettings.xml" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC, "word/webSettings.xml")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT, "word/webSettings.xml")

      expect(normalize_xml(roundtrip)).to be_xml_equivalent_to(normalize_xml(original))
    end
  end

  describe "word/numbering.xml" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC, "word/numbering.xml")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT, "word/numbering.xml")

      expect(normalize_xml(roundtrip)).to be_xml_equivalent_to(normalize_xml(original))
    end
  end

  describe "word/_rels/document.xml.rels" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC,
                                         "word/_rels/document.xml.rels")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT,
                                          "word/_rels/document.xml.rels")

      # The Reconciler may add relationships for present parts (e.g.,
      # theme) that weren't in the original. Check that all original
      # targets are present in the roundtrip (superset comparison).
      orig_targets = self.class.extract_rel_targets(original)
      trip_targets = self.class.extract_rel_targets(roundtrip)
      orig_targets.each { |t| expect(trip_targets).to include(t) }
    end
  end

  describe "word/theme/theme1.xml" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC, "word/theme/theme1.xml")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT, "word/theme/theme1.xml")

      skip "theme1.xml not found in original" if original.nil?
      expect(normalize_xml(roundtrip)).to be_xml_equivalent_to(normalize_xml(original))
    end
  end

  describe "word/theme/_rels/theme1.xml.rels" do
    it "preserves content through round-trip" do
      original = self.class.extract_file(COMPLETE_TEST_DOC,
                                         "word/theme/_rels/theme1.xml.rels")
      roundtrip = self.class.extract_file(COMPLETE_OUTPUT,
                                          "word/theme/_rels/theme1.xml.rels")

      skip "theme1.xml.rels not found in original" if original.nil?
      expect(normalize_xml(roundtrip)).to be_xml_equivalent_to(normalize_xml(original))
    end
  end
end
