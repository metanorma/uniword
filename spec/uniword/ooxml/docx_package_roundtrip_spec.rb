require 'spec_helper'
require 'canon/rspec_matchers'

RSpec.describe 'DocxPackage Complete Round-Trip' do
  TEST_DOCUMENT = 'examples/demo_formal_integral_proper.docx'
  OUTPUT_PATH = 'test_output/docx_package_complete.docx'

  before(:all) do
    require_relative '../../../lib/uniword/ooxml/docx_package'
    
    # Load and save with DocxPackage (proper OOP model)
    package = Uniword::Ooxml::DocxPackage.from_file(TEST_DOCUMENT)
    package.to_file(OUTPUT_PATH)
  end

  def self.extract_file(docx_path, file_path)
    require 'zip'
    Zip::File.open(docx_path) do |zip|
      entry = zip.find_entry(file_path)
      return entry ? entry.get_input_stream.read : nil
    end
  end

  # Test all 13 files
  describe '[Content_Types].xml' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, '[Content_Types].xml')
      roundtrip = self.class.extract_file(OUTPUT_PATH, '[Content_Types].xml')
      
      original_norm = XmlNormalizers.normalize_for_roundtrip(original)
      roundtrip_norm = XmlNormalizers.normalize_for_roundtrip(roundtrip)
      
      expect(roundtrip_norm).to be_xml_equivalent_to(original_norm)
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
      
      original_norm = XmlNormalizers.normalize_for_roundtrip(original)
      roundtrip_norm = XmlNormalizers.normalize_for_roundtrip(roundtrip)
      
      expect(roundtrip_norm).to be_xml_equivalent_to(original_norm)
    end
  end

  describe 'docProps/app.xml' do
    it 'preserves content through round-trip' do
      original = self.class.extract_file(TEST_DOCUMENT, 'docProps/app.xml')
      roundtrip = self.class.extract_file(OUTPUT_PATH, 'docProps/app.xml')
      
      original_norm = XmlNormalizers.normalize_for_roundtrip(original)
      roundtrip_norm = XmlNormalizers.normalize_for_roundtrip(roundtrip)
      
      expect(roundtrip_norm).to be_xml_equivalent_to(original_norm)
    end
  end
end
