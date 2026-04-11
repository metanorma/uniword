# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'zip'

RSpec.describe 'ISO Standard Document Testing', :integration do
  # Integration tests for ISO standard documents from spec/fixtures/uniword-private/fixtures/iso/
  # These are real ISO standards documents with complex track-changes and revision markup

  ISO_FIXTURES_DIR = File.join(__dir__, '../../spec/fixtures/uniword-private/fixtures/iso')

  # Dynamically discover all .docx files in the ISO fixtures directory
  ISO_DOCX_FILES = Dir.glob(File.join(ISO_FIXTURES_DIR, '*.docx')).freeze

  before(:all) do
    skip 'ISO fixtures not available' if ISO_DOCX_FILES.empty?
  end

  describe 'ISO Document Discovery' do
    it 'discovers ISO document fixtures' do
      expect(ISO_DOCX_FILES).not_to be_empty
      expect(ISO_DOCX_FILES).to all(match(/\.docx$/))
    end
  end

  describe 'ISO Document Validation' do
    ISO_DOCX_FILES.each do |docx_path|
      filename = File.basename(docx_path)

      describe filename do
        it 'is a valid DOCX (ZIP) file' do
          expect { Zip::File.open(docx_path) {} }.not_to raise_error
        end

        it 'contains required DOCX parts' do
          Zip::File.open(docx_path) do |zip|
            entries = zip.map(&:name)
            expect(entries).to include('[Content_Types].xml')
            expect(entries).to include('word/document.xml')
          end
        end

        it 'contains word/styles.xml' do
          Zip::File.open(docx_path) do |zip|
            entries = zip.map(&:name)
            expect(entries).to include('word/styles.xml')
          end
        end

        it 'has document relationships' do
          Zip::File.open(docx_path) do |zip|
            entries = zip.map(&:name)
            expect(entries).to include('word/_rels/document.xml.rels')
          end
        end

        it 'can report document.xml size' do
          Zip::File.open(docx_path) do |zip|
            entry = zip.find_entry('word/document.xml')
            expect(entry).not_to be_nil
          end
        end

        # NOTE: Loading tests (Uniword.load) are excluded from normal runs because
        # ISO documents have massive document.xml files (100MB+ uncompressed) due to
        # track-changes markup, causing 16+ minute hangs. Run with --tag iso_loading
        # to enable these tests when needed.
      end
    end
  end

  describe 'ISO Document Loading', :iso_loading do
    ISO_DOCX_FILES.each do |docx_path|
      filename = File.basename(docx_path)

      describe filename do
        it 'opens successfully' do
          expect { Uniword.load(docx_path) }.not_to raise_error
        end

        it 'returns a DocumentRoot' do
          doc = Uniword.load(docx_path)
          expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
        end

        it 'has paragraphs' do
          doc = Uniword.load(docx_path)
          expect(doc.paragraphs.count).to be > 0
        end

        it 'has a valid body' do
          doc = Uniword.load(docx_path)
          expect(doc.body).not_to be_nil
        end

        it 'has styles configuration' do
          doc = Uniword.load(docx_path)
          expect(doc.styles_configuration).not_to be_nil
          expect(doc.styles_configuration.styles.count).to be > 0
        end
      end
    end
  end
end
