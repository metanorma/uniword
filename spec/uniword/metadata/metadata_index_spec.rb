# frozen_string_literal: true

require 'spec_helper'
require 'uniword/metadata/metadata_index'
require 'uniword/metadata/metadata'
require 'tempfile'

RSpec.describe Uniword::Metadata::MetadataIndex do
  let(:index) { described_class.new }

  describe '#initialize' do
    it 'initializes with empty entries' do
      expect(index.entries).to eq({})
    end

    it 'loads export configuration' do
      expect(index.export_config).to be_a(Hash)
    end
  end

  describe '#add' do
    let(:metadata) { Uniword::Metadata::Metadata.new(title: 'Test') }

    it 'adds metadata entry' do
      index.add('doc.docx', metadata)

      expect(index.size).to eq(1)
    end

    it 'accepts Hash input' do
      index.add('doc.docx', { title: 'Test' })

      expect(index.size).to eq(1)
    end
  end

  describe '#get' do
    let(:metadata) { Uniword::Metadata::Metadata.new(title: 'Test') }

    before { index.add('doc.docx', metadata) }

    it 'retrieves metadata by path' do
      result = index.get('doc.docx')

      expect(result).to be_a(Uniword::Metadata::Metadata)
      expect(result[:title]).to eq('Test')
    end

    it 'returns nil for missing path' do
      expect(index.get('missing.docx')).to be_nil
    end
  end

  describe '#has?' do
    before { index.add('doc.docx', Uniword::Metadata::Metadata.new) }

    it 'checks if path exists' do
      expect(index.has?('doc.docx')).to be true
      expect(index.has?('missing.docx')).to be false
    end
  end

  describe '#remove' do
    let(:metadata) { Uniword::Metadata::Metadata.new(title: 'Test') }

    before { index.add('doc.docx', metadata) }

    it 'removes entry' do
      removed = index.remove('doc.docx')

      expect(removed).to be_a(Uniword::Metadata::Metadata)
      expect(index.size).to eq(0)
    end
  end

  describe '#size' do
    it 'returns entry count' do
      expect(index.size).to eq(0)

      index.add('doc1.docx', Uniword::Metadata::Metadata.new)
      index.add('doc2.docx', Uniword::Metadata::Metadata.new)

      expect(index.size).to eq(2)
    end
  end

  describe '#empty?' do
    it 'checks if index is empty' do
      expect(index.empty?).to be true

      index.add('doc.docx', Uniword::Metadata::Metadata.new)

      expect(index.empty?).to be false
    end
  end

  describe '#paths' do
    before do
      index.add('doc1.docx', Uniword::Metadata::Metadata.new)
      index.add('doc2.docx', Uniword::Metadata::Metadata.new)
    end

    it 'returns all paths' do
      paths = index.paths

      expect(paths).to match_array(['doc1.docx', 'doc2.docx'])
    end
  end

  describe '#all' do
    before do
      index.add('doc1.docx', Uniword::Metadata::Metadata.new(title: 'Doc1'))
      index.add('doc2.docx', Uniword::Metadata::Metadata.new(title: 'Doc2'))
    end

    it 'returns all metadata' do
      all = index.all

      expect(all).to be_a(Array)
      expect(all.size).to eq(2)
      expect(all.all? { |m| m.is_a?(Uniword::Metadata::Metadata) }).to be true
    end
  end

  describe '#filter' do
    before do
      index.add('doc1.docx', Uniword::Metadata::Metadata.new(author: 'John'))
      index.add('doc2.docx', Uniword::Metadata::Metadata.new(author: 'Jane'))
    end

    it 'filters entries by condition' do
      filtered = index.filter { |_path, meta| meta[:author] == 'John' }

      expect(filtered.size).to eq(1)
    end
  end

  describe '#find' do
    before do
      index.add('doc1.docx', Uniword::Metadata::Metadata.new(title: 'Test'))
      index.add('doc2.docx', Uniword::Metadata::Metadata.new(title: 'Other'))
    end

    it 'finds first matching entry' do
      result = index.find { |_path, meta| meta[:title] == 'Test' }

      expect(result).to be_a(Array)
      expect(result[0]).to eq('doc1.docx')
    end
  end

  describe '#query' do
    before do
      index.add('doc1.docx', Uniword::Metadata::Metadata.new(category: 'Report'))
      index.add('doc2.docx', Uniword::Metadata::Metadata.new(category: 'Letter'))
    end

    it 'queries by field value' do
      results = index.query(:category, 'Report')

      expect(results.size).to eq(1)
    end
  end

  describe '#export_json' do
    let(:tempfile) { Tempfile.new(['metadata', '.json']) }

    after { tempfile.unlink }

    it 'exports to JSON file' do
      index.add('doc.docx', Uniword::Metadata::Metadata.new(title: 'Test'))

      index.export_json(tempfile.path)

      expect(File.exist?(tempfile.path)).to be true
      content = File.read(tempfile.path)
      expect(content).to include('metadata_index')
    end

    it 'exports pretty JSON' do
      index.add('doc.docx', Uniword::Metadata::Metadata.new(title: 'Test'))

      index.export_json(tempfile.path, pretty: true)

      content = File.read(tempfile.path)
      expect(content).to include("\n") # Pretty printed
    end
  end

  describe '#export_yaml' do
    let(:tempfile) { Tempfile.new(['metadata', '.yml']) }

    after { tempfile.unlink }

    it 'exports to YAML file' do
      index.add('doc.docx', Uniword::Metadata::Metadata.new(title: 'Test'))

      index.export_yaml(tempfile.path)

      expect(File.exist?(tempfile.path)).to be true
    end
  end

  describe '#export_csv' do
    let(:tempfile) { Tempfile.new(['metadata', '.csv']) }

    after { tempfile.unlink }

    it 'exports to CSV file' do
      index.add('doc.docx', Uniword::Metadata::Metadata.new(
                              title: 'Test',
                              author: 'John'
                            ))

      index.export_csv(tempfile.path)

      expect(File.exist?(tempfile.path)).to be true
      content = File.read(tempfile.path)
      expect(content).to include('path')
    end

    it 'exports with custom columns' do
      index.add('doc.docx', Uniword::Metadata::Metadata.new(
                              title: 'Test',
                              author: 'John'
                            ))

      index.export_csv(tempfile.path, columns: [:title])

      content = File.read(tempfile.path)
      expect(content).to include('title')
    end
  end

  describe '#export_xml' do
    let(:tempfile) { Tempfile.new(['metadata', '.xml']) }

    after { tempfile.unlink }

    it 'exports to XML file' do
      index.add('doc.docx', Uniword::Metadata::Metadata.new(title: 'Test'))

      index.export_xml(tempfile.path)

      expect(File.exist?(tempfile.path)).to be true
      content = File.read(tempfile.path)
      expect(content).to include('<?xml')
    end
  end

  describe '#to_h' do
    before do
      index.add('doc.docx', Uniword::Metadata::Metadata.new(title: 'Test'))
    end

    it 'converts to hash' do
      hash = index.to_h

      expect(hash).to be_a(Hash)
      expect(hash).to have_key('doc.docx')
    end
  end

  describe '#to_a' do
    before do
      index.add('doc.docx', Uniword::Metadata::Metadata.new(title: 'Test'))
    end

    it 'converts to array' do
      array = index.to_a

      expect(array).to be_a(Array)
      expect(array.size).to eq(1)
      expect(array.first).to have_key(:path)
    end
  end

  describe '#merge' do
    let(:other_index) { described_class.new }

    before do
      index.add('doc1.docx', Uniword::Metadata::Metadata.new(title: 'Doc1'))
      other_index.add('doc2.docx', Uniword::Metadata::Metadata.new(title: 'Doc2'))
    end

    it 'merges with another index' do
      merged = index.merge(other_index)

      expect(merged.size).to eq(2)
      expect(index.size).to eq(1) # Original unchanged
    end
  end

  describe '#to_s' do
    it 'returns string representation' do
      expect(index.to_s).to include('MetadataIndex')
      expect(index.to_s).to include('0 documents')
    end
  end

  describe '#inspect' do
    it 'returns detailed inspection' do
      expect(index.inspect).to include('Uniword::Metadata::MetadataIndex')
    end
  end
end
