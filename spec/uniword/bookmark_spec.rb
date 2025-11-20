# frozen_string_literal: true

require 'spec_helper'
require 'uniword/bookmark'
require 'uniword/paragraph'

RSpec.describe Uniword::Bookmark do
  describe '#initialize' do
    it 'creates a bookmark with name' do
      bookmark = described_class.new(name: 'section1')

      expect(bookmark.name).to eq('section1')
      expect(bookmark.target_element).to be_nil
    end

    it 'creates a bookmark with name and target element' do
      paragraph = Uniword::Paragraph.new
      bookmark = described_class.new(name: 'intro', target_element: paragraph)

      expect(bookmark.name).to eq('intro')
      expect(bookmark.target_element).to eq(paragraph)
    end
  end

  describe '#target?' do
    it 'returns true when bookmark has target element' do
      paragraph = Uniword::Paragraph.new
      bookmark = described_class.new(name: 'test', target_element: paragraph)

      expect(bookmark.target?).to be true
    end

    it 'returns false when bookmark has no target element' do
      bookmark = described_class.new(name: 'test')

      expect(bookmark.target?).to be false
    end
  end

  describe '#anchor_name' do
    it 'returns sanitized anchor name' do
      bookmark = described_class.new(name: 'My Section!')

      expect(bookmark.anchor_name).to eq('my_section_')
    end

    it 'converts spaces to underscores' do
      bookmark = described_class.new(name: 'Section One')

      expect(bookmark.anchor_name).to eq('section_one')
    end

    it 'removes special characters' do
      bookmark = described_class.new(name: 'Section#1@Test')

      expect(bookmark.anchor_name).to eq('section_1_test')
    end

    it 'preserves hyphens and underscores' do
      bookmark = described_class.new(name: 'section-one_test')

      expect(bookmark.anchor_name).to eq('section-one_test')
    end

    it 'converts to lowercase' do
      bookmark = described_class.new(name: 'SECTION')

      expect(bookmark.anchor_name).to eq('section')
    end
  end

  describe '#to_h' do
    it 'returns hash representation' do
      paragraph = Uniword::Paragraph.new
      bookmark = described_class.new(name: 'test', target_element: paragraph)

      hash = bookmark.to_h

      expect(hash).to be_a(Hash)
      expect(hash[:name]).to eq('test')
      expect(hash[:target_element]).to eq(paragraph)
    end

    it 'includes nil target element in hash' do
      bookmark = described_class.new(name: 'test')

      hash = bookmark.to_h

      expect(hash[:target_element]).to be_nil
    end
  end

  describe '#==' do
    it 'returns true for bookmarks with same name' do
      bookmark1 = described_class.new(name: 'test')
      bookmark2 = described_class.new(name: 'test')

      expect(bookmark1).to eq(bookmark2)
    end

    it 'returns false for bookmarks with different names' do
      bookmark1 = described_class.new(name: 'test1')
      bookmark2 = described_class.new(name: 'test2')

      expect(bookmark1).not_to eq(bookmark2)
    end

    it 'returns false when comparing with non-bookmark' do
      bookmark = described_class.new(name: 'test')

      expect(bookmark).not_to eq('test')
    end

    it 'ignores target element in comparison' do
      p1 = Uniword::Paragraph.new
      p2 = Uniword::Paragraph.new
      bookmark1 = described_class.new(name: 'test', target_element: p1)
      bookmark2 = described_class.new(name: 'test', target_element: p2)

      expect(bookmark1).to eq(bookmark2)
    end
  end

  describe '#eql?' do
    it 'is alias for ==' do
      bookmark1 = described_class.new(name: 'test')
      bookmark2 = described_class.new(name: 'test')

      expect(bookmark1.eql?(bookmark2)).to be true
    end
  end

  describe '#hash' do
    it 'returns hash code based on name' do
      bookmark = described_class.new(name: 'test')

      expect(bookmark.hash).to eq('test'.hash)
    end

    it 'returns same hash for bookmarks with same name' do
      bookmark1 = described_class.new(name: 'test')
      bookmark2 = described_class.new(name: 'test')

      expect(bookmark1.hash).to eq(bookmark2.hash)
    end

    it 'allows bookmarks to be used in hash structures' do
      bookmark1 = described_class.new(name: 'test1')
      bookmark2 = described_class.new(name: 'test2')
      hash = { bookmark1 => 'value1', bookmark2 => 'value2' }

      expect(hash[bookmark1]).to eq('value1')
      expect(hash[bookmark2]).to eq('value2')
    end
  end

  describe 'attribute accessors' do
    it 'allows modification of name' do
      bookmark = described_class.new(name: 'test1')
      bookmark.name = 'test2'

      expect(bookmark.name).to eq('test2')
    end

    it 'allows modification of target element' do
      bookmark = described_class.new(name: 'test')
      paragraph = Uniword::Paragraph.new
      bookmark.target_element = paragraph

      expect(bookmark.target_element).to eq(paragraph)
    end
  end
end