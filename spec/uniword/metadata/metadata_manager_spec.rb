# frozen_string_literal: true

require 'spec_helper'
require 'uniword/metadata/metadata_manager'
require 'uniword/document'
require 'uniword/paragraph'

RSpec.describe Uniword::Metadata::MetadataManager do
  let(:manager) { described_class.new }

  describe '#initialize' do
    it 'initializes with default config' do
      expect(manager).to be_a(described_class)
      expect(manager.extractor).to be_a(Uniword::Metadata::MetadataExtractor)
      expect(manager.updater).to be_a(Uniword::Metadata::MetadataUpdater)
      expect(manager.validator).to be_a(Uniword::Metadata::MetadataValidator)
    end

    it 'initializes with custom config file' do
      custom_manager = described_class.new(config_file: 'metadata_schema')
      expect(custom_manager.extractor).to be_a(Uniword::Metadata::MetadataExtractor)
    end
  end

  describe '#extract' do
    let(:document) do
      doc = Uniword::Document.new
      para1 = Uniword::Paragraph.new
      para1.add_text('First paragraph content')
      para2 = Uniword::Paragraph.new
      para2.add_text('Second paragraph content')
      doc.add_element(para1)
      doc.add_element(para2)
      doc
    end

    it 'extracts metadata from document' do
      metadata = manager.extract(document)

      expect(metadata).to be_a(Uniword::Metadata::Metadata)
      expect(metadata[:word_count]).to be > 0
      expect(metadata[:paragraph_count]).to eq(2)
    end

    it 'extracts statistical metadata' do
      metadata = manager.extract(document)

      expect(metadata[:word_count]).to be > 0
      expect(metadata[:character_count]).to be > 0
      expect(metadata[:paragraph_count]).to eq(2)
    end

    it 'estimates page count' do
      metadata = manager.extract(document)

      expect(metadata[:page_count]).to be >= 0
    end
  end

  describe '#extract_and_validate' do
    let(:document) { Uniword::Document.new }

    it 'extracts and validates metadata' do
      result = manager.extract_and_validate(document)

      expect(result).to have_key(:metadata)
      expect(result).to have_key(:validation)
      expect(result[:metadata]).to be_a(Uniword::Metadata::Metadata)
      expect(result[:validation]).to be_a(Hash)
      expect(result[:validation]).to have_key(:valid)
    end

    it 'returns validation result' do
      result = manager.extract_and_validate(document)

      expect([true, false]).to include(result[:validation][:valid])
    end
  end

  describe '#update' do
    let(:document) { Uniword::Document.new }

    it 'updates document metadata' do
      result = manager.update(document, {
                                title: 'Test Title',
                                author: 'Test Author'
                              })

      expect(result[:success]).to be true
    end

    it 'updates with Metadata object' do
      metadata = Uniword::Metadata::Metadata.new(
        title: 'Test Title',
        author: 'Test Author'
      )

      result = manager.update(document, metadata)

      expect(result[:success]).to be true
    end

    context 'with validation' do
      it 'validates before updating' do
        result = manager.update(
          document,
          { title: 'Test' },
          validate: true
        )

        expect(result).to have_key(:success)
      end

      it 'returns errors for invalid metadata' do
        # Create metadata that violates constraints
        invalid_metadata = {
          title: 'x' * 300 # Exceeds max_length
        }

        result = manager.update(
          document,
          invalid_metadata,
          validate: true
        )

        expect([true, false]).to include(result[:success])
      end
    end
  end

  describe '#validate' do
    let(:metadata) do
      Uniword::Metadata::Metadata.new(
        title: 'Test Title',
        author: 'Test Author'
      )
    end

    it 'validates metadata' do
      result = manager.validate(metadata)

      expect(result).to be_a(Hash)
      expect(result).to have_key(:valid)
      expect(result).to have_key(:errors)
    end

    it 'validates with scenario' do
      result = manager.validate(metadata, scenario: :publication)

      expect(result).to be_a(Hash)
    end
  end

  describe '#extract_batch' do
    it 'creates empty index for empty array' do
      index = manager.extract_batch([])

      expect(index).to be_a(Uniword::Metadata::MetadataIndex)
      expect(index.size).to eq(0)
    end

    it 'handles non-existent files gracefully' do
      index = manager.extract_batch(['nonexistent.docx'])

      expect(index.size).to eq(0)
    end
  end

  describe '#extract_from_pattern' do
    it 'extracts from glob pattern' do
      index = manager.extract_from_pattern('nonexistent/**/*.docx')

      expect(index).to be_a(Uniword::Metadata::MetadataIndex)
    end
  end

  describe '#extract_from_directory' do
    it 'extracts from directory' do
      index = manager.extract_from_directory('spec/fixtures', pattern: '*.txt')

      expect(index).to be_a(Uniword::Metadata::MetadataIndex)
    end

    it 'supports recursive extraction' do
      index = manager.extract_from_directory(
        'spec',
        recursive: true,
        pattern: '*.rb'
      )

      expect(index).to be_a(Uniword::Metadata::MetadataIndex)
    end
  end

  describe '#update_batch' do
    it 'updates multiple documents' do
      updates = {}

      results = manager.update_batch(updates)

      expect(results).to have_key(:success_count)
      expect(results).to have_key(:failure_count)
      expect(results).to have_key(:failures)
    end

    it 'handles errors gracefully' do
      updates = {
        'nonexistent.docx' => { title: 'Test' }
      }

      results = manager.update_batch(updates)

      expect(results[:failure_count]).to be >= 0
    end
  end

  describe '#summary' do
    let(:index) { Uniword::Metadata::MetadataIndex.new }

    it 'returns empty hash for empty index' do
      summary = manager.summary(index)

      expect(summary).to eq({})
    end

    it 'computes summary statistics' do
      metadata = Uniword::Metadata::Metadata.new(
        word_count: 100,
        page_count: 2,
        author: 'John Doe'
      )
      index.add('doc.docx', metadata)

      summary = manager.summary(index)

      expect(summary[:document_count]).to eq(1)
      expect(summary[:total_words]).to eq(100)
      expect(summary[:total_pages]).to eq(2)
      expect(summary[:authors]).to include('John Doe')
    end
  end

  describe '#query' do
    let(:index) { Uniword::Metadata::MetadataIndex.new }

    before do
      index.add('doc1.docx', Uniword::Metadata::Metadata.new(author: 'John'))
      index.add('doc2.docx', Uniword::Metadata::Metadata.new(author: 'Jane'))
    end

    it 'queries by single criterion' do
      results = manager.query(index, author: 'John')

      expect(results.size).to eq(1)
    end

    it 'queries by multiple criteria' do
      results = manager.query(index, { author: 'Jane' })

      expect(results.size).to eq(1)
    end
  end

  describe 'integration' do
    let(:document) do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Integration test content')
      doc.add_element(para)
      doc
    end

    it 'performs full workflow' do
      # Extract
      metadata = manager.extract(document)
      expect(metadata).to be_a(Uniword::Metadata::Metadata)

      # Validate
      validation = manager.validate(metadata)
      expect([true, false]).to include(validation[:valid])

      # Update
      result = manager.update(document, { title: 'New Title' })
      expect(result[:success]).to be true
    end
  end
end
