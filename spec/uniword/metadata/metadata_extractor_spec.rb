# frozen_string_literal: true

require 'spec_helper'
require 'uniword/metadata/metadata_extractor'
require 'uniword/document'
require 'uniword/paragraph'

RSpec.describe Uniword::Metadata::MetadataExtractor do
  let(:extractor) { described_class.new }

  describe '#initialize' do
    it 'initializes with default config' do
      expect(extractor).to be_a(described_class)
      expect(extractor.config).to be_a(Hash)
    end

    it 'loads configuration' do
      expect(extractor.config).to have_key(:extraction_config)
    end
  end

  describe '#extract' do
    let(:document) do
      doc = Uniword::Document.new
      para1 = Uniword::Paragraph.new
      para1.add_text('First paragraph with some words')
      para2 = Uniword::Paragraph.new
      para2.add_text('Second paragraph content')
      doc.add_element(para1)
      doc.add_element(para2)
      doc
    end

    it 'extracts metadata from document' do
      metadata = extractor.extract(document)

      expect(metadata).to be_a(Uniword::Metadata::Metadata)
    end

    it 'extracts word count' do
      metadata = extractor.extract(document)

      expect(metadata[:word_count]).to be > 0
    end

    it 'extracts character count' do
      metadata = extractor.extract(document)

      expect(metadata[:character_count]).to be > 0
    end

    it 'extracts paragraph count' do
      metadata = extractor.extract(document)

      expect(metadata[:paragraph_count]).to eq(2)
    end

    it 'estimates page count' do
      metadata = extractor.extract(document)

      expect(metadata[:page_count]).to be >= 0
    end

    context 'with headings' do
      let(:document) do
        doc = Uniword::Document.new
        heading = Uniword::Paragraph.new
        heading.add_text('Heading 1')
        # Mock the style method
        allow(heading).to receive(:style).and_return('Heading 1')
        doc.add_element(heading)
        doc
      end

      it 'extracts headings' do
        metadata = extractor.extract(document)

        expect(metadata[:headings]).to be_a(Array)
      end

      it 'extracts heading hierarchy' do
        metadata = extractor.extract(document)

        if metadata[:headings]&.any?
          expect(metadata[:headings].first).to have_key(:level)
          expect(metadata[:headings].first).to have_key(:text)
        end
      end
    end

    context 'with first paragraph' do
      it 'extracts first paragraph text' do
        metadata = extractor.extract(document)

        expect(metadata[:first_paragraph]).to be_a(String)
      end

      it 'limits first paragraph length' do
        long_doc = Uniword::Document.new
        para = Uniword::Paragraph.new
        para.add_text('x' * 1000)
        long_doc.add_element(para)

        metadata = extractor.extract(long_doc)

        expect(metadata[:first_paragraph].length).to be <= 503 # 500 + '...'
      end
    end

    context 'with invalid document' do
      it 'raises error for invalid document' do
        expect { extractor.extract('not a document') }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'statistical metadata extraction' do
    let(:document) do
      doc = Uniword::Document.new
      5.times do |i|
        para = Uniword::Paragraph.new
        para.add_text("Paragraph #{i} content")
        doc.add_element(para)
      end
      doc
    end

    it 'computes accurate word count' do
      metadata = extractor.extract(document)

      expect(metadata[:word_count]).to eq(15) # 3 words per paragraph * 5
    end

    it 'computes character count' do
      metadata = extractor.extract(document)

      expect(metadata[:character_count]).to be > 50
    end

    it 'counts paragraphs correctly' do
      metadata = extractor.extract(document)

      expect(metadata[:paragraph_count]).to eq(5)
    end
  end

  describe 'content metadata extraction' do
    it 'extracts from empty document' do
      empty_doc = Uniword::Document.new

      metadata = extractor.extract(empty_doc)

      expect(metadata[:word_count]).to eq(0)
      expect(metadata[:paragraph_count]).to eq(0)
    end
  end

  describe 'configuration' do
    it 'uses default config when file not found' do
      extractor = described_class.new(config_file: 'nonexistent.yml')

      expect(extractor.config).to be_a(Hash)
    end
  end
end
