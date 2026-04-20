# frozen_string_literal: true

require "spec_helper"
require "canon/rspec_matchers"

RSpec.describe "DocxPackage Complete Round-Trip" do
  TEST_DOCUMENT = "spec/fixtures/uniword-demo/demo_formal_integral_proper.docx"
  OUTPUT_PATH = "test_output/docx_package_complete.docx"

  before(:context) do
    # Load and save with DocxPackage (proper OOP model)
    package = Uniword::Docx::Package.from_file(TEST_DOCUMENT)
    package.to_file(OUTPUT_PATH)
  end

  # Inline the shared example checks to avoid before(:all)/it_behaves_like
  # interaction issues where shared examples run in a separate nested group
  # that may not inherit the parent's before(:all) state on CI.
  it "is a valid ZIP file" do
    expect(Zip::File.open(OUTPUT_PATH) { |z| z.entries.count }).to be > 0
  end

  it "contains [Content_Types].xml" do
    content = ZipHelper.extract_file(OUTPUT_PATH, "[Content_Types].xml")
    expect(content).to include("Types")
  end

  it "contains _rels/.rels" do
    content = ZipHelper.extract_file(OUTPUT_PATH, "_rels/.rels")
    expect(content).to include("Relationships")
  end

  it "contains word/document.xml" do
    content = ZipHelper.extract_file(OUTPUT_PATH, "word/document.xml")
    expect(content).to include("document")
  end

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
