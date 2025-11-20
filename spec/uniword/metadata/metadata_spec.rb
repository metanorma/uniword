# frozen_string_literal: true

require 'spec_helper'
require 'uniword/metadata/metadata'

RSpec.describe Uniword::Metadata::Metadata do
  let(:metadata) { described_class.new }

  describe '#initialize' do
    it 'initializes with empty properties' do
      expect(metadata.properties).to eq({})
    end

    it 'initializes with properties' do
      meta = described_class.new(title: 'Test', author: 'John')
      expect(meta[:title]).to eq('Test')
      expect(meta[:author]).to eq('John')
    end

    it 'symbolizes string keys' do
      meta = described_class.new('title' => 'Test')
      expect(meta[:title]).to eq('Test')
    end
  end

  describe '#[]' do
    it 'gets property value' do
      metadata[:title] = 'Test Title'
      expect(metadata[:title]).to eq('Test Title')
    end

    it 'returns nil for missing property' do
      expect(metadata[:nonexistent]).to be_nil
    end

    it 'accepts string keys' do
      metadata[:title] = 'Test'
      expect(metadata['title']).to eq('Test')
    end
  end

  describe '#[]=' do
    it 'sets property value' do
      metadata[:title] = 'New Title'
      expect(metadata[:title]).to eq('New Title')
    end

    it 'symbolizes string keys' do
      metadata['author'] = 'John'
      expect(metadata[:author]).to eq('John')
    end
  end

  describe '#get' do
    it 'gets value with default' do
      expect(metadata.get(:missing, 'default')).to eq('default')
    end

    it 'returns value if present' do
      metadata[:title] = 'Test'
      expect(metadata.get(:title, 'default')).to eq('Test')
    end
  end

  describe '#has_key?' do
    it 'checks if key exists' do
      metadata[:title] = 'Test'
      expect(metadata.has_key?(:title)).to be true
      expect(metadata.has_key?(:missing)).to be false
    end
  end

  describe '#keys' do
    it 'returns all keys' do
      metadata[:title] = 'Test'
      metadata[:author] = 'John'
      expect(metadata.keys).to match_array([:title, :author])
    end
  end

  describe '#values' do
    it 'returns all values' do
      metadata[:title] = 'Test'
      metadata[:author] = 'John'
      expect(metadata.values).to match_array(['Test', 'John'])
    end
  end

  describe '#merge' do
    it 'merges with another metadata' do
      metadata[:title] = 'Original'
      other = described_class.new(author: 'John')

      result = metadata.merge(other)

      expect(result[:title]).to eq('Original')
      expect(result[:author]).to eq('John')
      expect(metadata[:author]).to be_nil  # Original unchanged
    end

    it 'merges with hash' do
      metadata[:title] = 'Original'

      result = metadata.merge(author: 'John')

      expect(result[:author]).to eq('John')
    end
  end

  describe '#merge!' do
    it 'merges in place' do
      metadata[:title] = 'Original'
      other = described_class.new(author: 'John')

      metadata.merge!(other)

      expect(metadata[:author]).to eq('John')
    end
  end

  describe '#select' do
    it 'selects properties' do
      metadata[:title] = 'Test'
      metadata[:author] = 'John'
      metadata[:pages] = 10

      result = metadata.select { |k, v| v.is_a?(String) }

      expect(result.keys).to match_array([:title, :author])
    end
  end

  describe '#reject' do
    it 'rejects properties' do
      metadata[:title] = 'Test'
      metadata[:author] = nil

      result = metadata.reject { |k, v| v.nil? }

      expect(result.keys).to eq([:title])
    end
  end

  describe '#to_h' do
    it 'converts to hash' do
      metadata[:title] = 'Test'
      metadata[:author] = 'John'

      hash = metadata.to_h

      expect(hash).to be_a(Hash)
      expect(hash[:title]).to eq('Test')
    end

    it 'excludes nil values when requested' do
      metadata[:title] = 'Test'
      metadata[:author] = nil

      hash = metadata.to_h(include_nil: false)

      expect(hash.keys).to eq([:title])
    end

    it 'includes nil values by default' do
      metadata[:title] = 'Test'
      metadata[:author] = nil

      hash = metadata.to_h

      expect(hash.keys).to match_array([:title, :author])
    end
  end

  describe '#to_json_hash' do
    it 'converts to JSON-compatible hash' do
      metadata[:title] = 'Test'
      metadata[:count] = 10

      hash = metadata.to_json_hash

      expect(hash).to be_a(Hash)
      expect(hash['title']).to eq('Test')
      expect(hash['count']).to eq(10)
    end

    it 'formats datetime values' do
      time = Time.now
      metadata[:created_at] = time

      hash = metadata.to_json_hash

      expect(hash['created_at']).to eq(time.iso8601)
    end
  end

  describe '#to_yaml_hash' do
    it 'converts to YAML-compatible hash' do
      metadata[:title] = 'Test'

      hash = metadata.to_yaml_hash

      expect(hash).to be_a(Hash)
      expect(hash['title']).to eq('Test')
    end
  end

  describe '#empty?' do
    it 'returns true for empty metadata' do
      expect(metadata.empty?).to be true
    end

    it 'returns false for non-empty metadata' do
      metadata[:title] = 'Test'
      expect(metadata.empty?).to be false
    end
  end

  describe '#size' do
    it 'returns property count' do
      metadata[:title] = 'Test'
      metadata[:author] = 'John'
      expect(metadata.size).to eq(2)
    end
  end

  describe 'method_missing' do
    it 'accesses properties as methods' do
      metadata[:title] = 'Test'
      expect(metadata.title).to eq('Test')
    end

    it 'sets properties as methods' do
      metadata.title = 'New Title'
      expect(metadata[:title]).to eq('New Title')
    end

    it 'raises for unknown methods' do
      expect { metadata.unknown_method(1, 2, 3) }.to raise_error(NoMethodError)
    end
  end

  describe 'respond_to_missing?' do
    it 'responds to property getters' do
      metadata[:title] = 'Test'
      expect(metadata.respond_to?(:title)).to be true
    end

    it 'responds to property setters' do
      expect(metadata.respond_to?(:title=)).to be true
    end
  end

  describe '#==' do
    it 'compares metadata equality' do
      meta1 = described_class.new(title: 'Test')
      meta2 = described_class.new(title: 'Test')

      expect(meta1).to eq(meta2)
    end

    it 'returns false for different metadata' do
      meta1 = described_class.new(title: 'Test1')
      meta2 = described_class.new(title: 'Test2')

      expect(meta1).not_to eq(meta2)
    end
  end

  describe '#dup' do
    it 'duplicates metadata' do
      metadata[:title] = 'Test'
      copy = metadata.dup

      copy[:title] = 'Modified'

      expect(metadata[:title]).to eq('Test')
      expect(copy[:title]).to eq('Modified')
    end
  end

  describe '#clone' do
    it 'clones metadata' do
      metadata[:title] = 'Test'
      metadata[:tags] = ['tag1', 'tag2']

      copy = metadata.clone
      copy[:tags] << 'tag3'

      expect(metadata[:tags].size).to eq(2)
      expect(copy[:tags].size).to eq(3)
    end
  end

  describe '#to_s' do
    it 'returns string representation' do
      metadata[:title] = 'Test'
      expect(metadata.to_s).to include('Metadata')
      expect(metadata.to_s).to include('1 properties')
    end
  end

  describe '#inspect' do
    it 'returns detailed inspection' do
      metadata[:title] = 'Test'
      expect(metadata.inspect).to include('Uniword::Metadata::Metadata')
      expect(metadata.inspect).to include('title')
    end
  end
end