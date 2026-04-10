# frozen_string_literal: true

require 'spec_helper'
require 'canon/rspec_matchers'

RSpec.describe 'Document Elements Round-Trip' do
  DOCUMENT_ELEMENTS_DIR = File.join(__dir__,
                                    '../../spec/fixtures/uniword-private/word-resources/document-elements/en')

  # All 8 document element reference files
  DOCUMENT_ELEMENT_FILES = {
    'Bibliographies.dotx' => 'bibliography',
    'Cover Pages.dotx' => 'cover_page',
    'Equations.dotx' => 'equation',
    'Footers.dotx' => 'footer',
    'Headers.dotx' => 'header',
    'Table of Contents.dotx' => 'toc',
    'Tables.dotx' => 'table',
    'Watermarks.dotx' => 'watermark'
  }.freeze

  DOCUMENT_ELEMENT_FILES.each_key do |filename|
    describe filename do
      let(:dotx_path) { File.join(DOCUMENT_ELEMENTS_DIR, filename) }
      let(:temp_dir) { Dir.mktmpdir }
      let(:extracted_dir) { File.join(temp_dir, 'extracted') }
      let(:roundtrip_dir) { File.join(temp_dir, 'roundtrip') }

      after do
        FileUtils.rm_rf(temp_dir)
      end

      context 'Glossary Document' do
        let(:glossary_xml_path) { File.join(extracted_dir, 'word/glossary/document.xml') }
        let(:glossary_roundtrip_path) { File.join(roundtrip_dir, 'word/glossary/document.xml') }

        it "round-trips #{filename} glossary document" do
          # Extract original
          FileUtils.mkdir_p(extracted_dir)
          system("unzip -q '#{dotx_path}' -d '#{extracted_dir}'")

          # Skip if no glossary document exists
          next unless File.exist?(glossary_xml_path)

          # Read original XML
          original_xml = File.read(glossary_xml_path)

          # Parse with Uniword
          glossary_doc = Uniword::Glossary::GlossaryDocument.from_xml(original_xml)

          # Serialize back
          roundtrip_xml = glossary_doc.to_xml(pretty: false)

          # Write roundtrip for comparison
          FileUtils.mkdir_p(File.dirname(glossary_roundtrip_path))
          File.write(glossary_roundtrip_path, roundtrip_xml)

          # Compare using Canon (spec_friendly: ignores structural whitespace differences)
          expect(roundtrip_xml).to be_xml_equivalent_to(original_xml,
                                                        match_profile: :spec_friendly)
        end
      end

      context '[Content_Types].xml' do
        it "preserves #{filename} content types" do
          # Extract original
          FileUtils.mkdir_p(extracted_dir)
          system("unzip -q '#{dotx_path}' -d '#{extracted_dir}'")

          content_types_path = File.join(extracted_dir, '[Content_Types].xml')
          expect(File.exist?(content_types_path)).to be true

          original_xml = File.read(content_types_path)
          expect(original_xml).to include('application/vnd.openxmlformats-officedocument')
        end
      end
    end
  end
end
