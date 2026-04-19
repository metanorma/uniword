# frozen_string_literal: true

require "spec_helper"
require "canon/rspec_matchers"

RSpec.describe "DocxPackage Complete Round-Trip" do
  TEST_DOCUMENT = "spec/fixtures/uniword-demo/demo_formal_integral_proper.docx"
  OUTPUT_PATH = "test_output/docx_package_complete.docx"

  before(:all) do
    # Load and save with DocxPackage (proper OOP model)
    package = Uniword::Docx::Package.from_file(TEST_DOCUMENT)
    package.to_file(OUTPUT_PATH)
  end

  it_behaves_like "a valid DOCX package", OUTPUT_PATH

  # Verify key XML files preserve through round-trip
  %w[[Content_Types].xml _rels/.rels docProps/core.xml docProps/app.xml
     word/document.xml word/styles.xml word/settings.xml
     word/fontTable.xml word/webSettings.xml].each do |xml_file|
    describe xml_file do
      it "preserves content through round-trip" do
        original = ZipHelper.extract_file(TEST_DOCUMENT, xml_file)
        roundtrip = ZipHelper.extract_file(OUTPUT_PATH, xml_file)
        skip "#{xml_file} not in original" unless original

        normalized_orig = XmlNormalizers.normalize_for_roundtrip(original)
        normalized_rt = XmlNormalizers.normalize_for_roundtrip(roundtrip)

        expect(normalized_rt).to be_xml_equivalent_to(normalized_orig)
      end
    end
  end
end
