# frozen_string_literal: true

require 'spec_helper'
require 'canon/rspec_matchers'

RSpec.describe 'Complete DOCX Round-Trip Fidelity' do
  TEST_DOCUMENT = 'examples/demo_formal_integral_proper.docx'
  OUTPUT_PATH = 'test_output/complete_roundtrip.docx'

  # List of all XML files to test (13 files total for Week 1 goal)
  XML_FILES = [
    '[Content_Types].xml',
    '_rels/.rels',
    'docProps/core.xml',
    'docProps/app.xml',
    'word/document.xml',
    'word/styles.xml',
    'word/fontTable.xml',
    'word/settings.xml',
    'word/webSettings.xml',
    'word/numbering.xml',
    'word/_rels/document.xml.rels',
    'word/theme/theme1.xml',
    'word/theme/_rels/theme1.xml.rels'
  ].freeze

  before(:all) do
    # Load and save document once for all tests
    doc = Uniword.load(TEST_DOCUMENT)
    doc.save(OUTPUT_PATH)
  end

  def self.extract_file(docx_path, file_path)
    require 'zip'
    Zip::File.open(docx_path) do |zip|
      entry = zip.find_entry(file_path)
      return entry&.get_input_stream&.read
    end
  end

  # Create individual test for each XML file
  describe '[Content_Types].xml' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, '[Content_Types].xml')
      roundtrip = self.class.extract_file(OUTPUT_PATH, '[Content_Types].xml')
      expect(roundtrip).to be_xml_equivalent_to(original)
    end
  end

  describe '_rels/.rels' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, '_rels/.rels')
      roundtrip = self.class.extract_file(OUTPUT_PATH, '_rels/.rels')
      expect(roundtrip).to be_xml_equivalent_to(original)
    end
  end

  describe 'docProps/core.xml' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, 'docProps/core.xml')
      roundtrip = self.class.extract_file(OUTPUT_PATH, 'docProps/core.xml')

      # Apply normalization for known issues (temporary workarounds):
      # 1. DateTime serialization uses +00:00 instead of Z (both valid ISO 8601)
      # 2. Missing xmlns:dcmitype declaration (unused namespace)
      original_normalized = XmlNormalizers.normalize_for_roundtrip(original)
      roundtrip_normalized = XmlNormalizers.normalize_for_roundtrip(roundtrip)

      expect(roundtrip_normalized).to be_xml_equivalent_to(original_normalized)
    end
  end

  describe 'docProps/app.xml' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, 'docProps/app.xml')
      roundtrip = self.class.extract_file(OUTPUT_PATH, 'docProps/app.xml')

      # Apply normalization for consistency
      original_normalized = XmlNormalizers.normalize_for_roundtrip(original)
      roundtrip_normalized = XmlNormalizers.normalize_for_roundtrip(roundtrip)

      expect(roundtrip_normalized).to be_xml_equivalent_to(original_normalized)
    end
  end

  describe 'word/document.xml' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, 'word/document.xml')
      roundtrip = self.class.extract_file(OUTPUT_PATH, 'word/document.xml')
      expect(roundtrip).to be_xml_equivalent_to(original)
    end
  end

  describe 'word/styles.xml' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, 'word/styles.xml')
      roundtrip = self.class.extract_file(OUTPUT_PATH, 'word/styles.xml')
      expect(roundtrip).to be_xml_equivalent_to(original)
    end
  end

  describe 'word/fontTable.xml' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, 'word/fontTable.xml')
      roundtrip = self.class.extract_file(OUTPUT_PATH, 'word/fontTable.xml')
      expect(roundtrip).to be_xml_equivalent_to(original)
    end
  end

  describe 'word/settings.xml' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, 'word/settings.xml')
      roundtrip = self.class.extract_file(OUTPUT_PATH, 'word/settings.xml')
      expect(roundtrip).to be_xml_equivalent_to(original)
    end
  end

  describe 'word/webSettings.xml' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, 'word/webSettings.xml')
      roundtrip = self.class.extract_file(OUTPUT_PATH, 'word/webSettings.xml')
      expect(roundtrip).to be_xml_equivalent_to(original)
    end
  end

  describe 'word/numbering.xml' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, 'word/numbering.xml')
      roundtrip = self.class.extract_file(OUTPUT_PATH, 'word/numbering.xml')
      expect(roundtrip).to be_xml_equivalent_to(original)
    end
  end

  describe 'word/_rels/document.xml.rels' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, 'word/_rels/document.xml.rels')
      roundtrip = self.class.extract_file(OUTPUT_PATH, 'word/_rels/document.xml.rels')
      expect(roundtrip).to be_xml_equivalent_to(original)
    end
  end

  describe 'word/theme/theme1.xml' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, 'word/theme/theme1.xml')
      roundtrip = self.class.extract_file(OUTPUT_PATH, 'word/theme/theme1.xml')

      skip 'theme1.xml not found in original' if original.nil?
      expect(roundtrip).to be_xml_equivalent_to(original)
    end
  end

  describe 'word/theme/_rels/theme1.xml.rels' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, 'word/theme/_rels/theme1.xml.rels')
      roundtrip = self.class.extract_file(OUTPUT_PATH, 'word/theme/_rels/theme1.xml.rels')

      skip 'theme1.xml.rels not found in original' if original.nil?
      expect(roundtrip).to be_xml_equivalent_to(original)
    end
  end
end
