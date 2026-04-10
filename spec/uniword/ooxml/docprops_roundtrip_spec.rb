# frozen_string_literal: true

require 'spec_helper'
require 'canon/rspec_matchers'

RSpec.describe 'DocProps Round-Trip Fidelity' do
  let(:test_document) { 'spec/fixtures/uniword-demo/demo_formal_integral_proper.docx' }
  let(:output_path) { 'test_output/docprops_roundtrip.docx' }

  before(:all) do
    # Load and save document once for all tests
    package = Uniword::Ooxml::DocxPackage.from_file('spec/fixtures/uniword-demo/demo_formal_integral_proper.docx')
    package.to_file('test_output/docprops_roundtrip.docx')
  end

  def extract_file(docx_path, file_path)
    require 'zip'
    Zip::File.open(docx_path) do |zip|
      entry = zip.find_entry(file_path)
      return entry&.get_input_stream&.read
    end
  end

  describe 'docProps/core.xml' do
    it 'preserves core properties through round-trip' do
      original = extract_file(test_document, 'docProps/core.xml')
      roundtrip = extract_file(output_path, 'docProps/core.xml')

      # Normalize both for comparison (handles timestamp format and unused namespaces)
      original_normalized = XmlNormalizers.normalize_for_roundtrip(original)
      roundtrip_normalized = XmlNormalizers.normalize_for_roundtrip(roundtrip)

      expect(roundtrip_normalized).to be_xml_equivalent_to(original_normalized)
    end
  end

  describe 'docProps/app.xml' do
    it 'preserves app properties through round-trip' do
      original = extract_file(test_document, 'docProps/app.xml')
      roundtrip = extract_file(output_path, 'docProps/app.xml')

      # Normalize both for comparison
      original_normalized = XmlNormalizers.normalize_for_roundtrip(original)
      roundtrip_normalized = XmlNormalizers.normalize_for_roundtrip(roundtrip)

      expect(roundtrip_normalized).to be_xml_equivalent_to(original_normalized)
    end
  end
end
