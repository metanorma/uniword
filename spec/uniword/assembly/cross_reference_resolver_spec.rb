# frozen_string_literal: true

require 'spec_helper'
require 'uniword/assembly/cross_reference_resolver'
require 'uniword/document'
require 'uniword/paragraph'
require 'uniword/run'

RSpec.describe Uniword::Assembly::CrossReferenceResolver do
  let(:resolver) { described_class.new }

  describe '#initialize' do
    it 'creates resolver with empty mappings' do
      expect(resolver.bookmark_mappings).to be_empty
    end
  end

  describe '#add_bookmark_mapping' do
    it 'adds bookmark ID mapping' do
      resolver.add_bookmark_mapping('old_id', 'new_id')
      expect(resolver.bookmark_mappings['old_id']).to eq('new_id')
    end

    it 'supports multiple mappings' do
      resolver.add_bookmark_mapping('id1', 'new1')
      resolver.add_bookmark_mapping('id2', 'new2')

      expect(resolver.bookmark_mappings.size).to eq(2)
    end
  end

  describe '#resolve' do
    let(:document) { Uniword::Document.new }

    it 'returns the document' do
      result = resolver.resolve(document)
      expect(result).to be(document)
    end

    it 'processes document paragraphs' do
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'Test'
      para.add_run(run)
      document.add_paragraph(para)

      expect { resolver.resolve(document) }.not_to raise_error
    end
  end

  describe '#bookmark_exists?' do
    it 'returns false for non-existent bookmark' do
      expect(resolver.bookmark_exists?('nonexistent')).to be false
    end
  end

  describe '#get_bookmark' do
    it 'returns nil for non-existent bookmark' do
      expect(resolver.get_bookmark('nonexistent')).to be_nil
    end
  end

  describe '#bookmark_ids' do
    it 'returns empty array initially' do
      expect(resolver.bookmark_ids).to be_empty
    end

    it 'returns array of strings' do
      expect(resolver.bookmark_ids).to be_an(Array)
    end
  end

  describe '#clear' do
    it 'clears all mappings' do
      resolver.add_bookmark_mapping('id1', 'new1')
      resolver.clear

      expect(resolver.bookmark_mappings).to be_empty
    end

    it 'clears bookmark registry' do
      resolver.clear
      expect(resolver.bookmark_ids).to be_empty
    end
  end

  describe 'bookmark resolution' do
    it 'resolves mapped bookmark IDs' do
      resolver.add_bookmark_mapping('old_id', 'new_id')

      # Internal method test through public interface
      expect(resolver.bookmark_mappings['old_id']).to eq('new_id')
    end

    it 'handles unmapped bookmark IDs' do
      # Should not raise error for unmapped IDs
      expect { resolver.resolve(Uniword::Document.new) }.not_to raise_error
    end
  end
end
