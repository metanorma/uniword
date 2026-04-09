# frozen_string_literal: true

require 'spec_helper'
require 'uniword/endnote'

RSpec.describe Uniword::Endnote do
  describe '#initialize' do
    it 'creates an endnote with id and content' do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      endnote = described_class.new(id: 1, content: [paragraph])

      expect(endnote.id).to eq(1)
      expect(endnote.content).to eq([paragraph])
    end

    it 'creates an endnote with default empty content' do
      endnote = described_class.new(id: 2)

      expect(endnote.id).to eq(2)
      expect(endnote.content).to eq([])
    end

    it 'accepts string id' do
      endnote = described_class.new(id: 'en1')

      expect(endnote.id).to eq('en1')
    end
  end

  describe '#content?' do
    it 'returns true when endnote has content' do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      endnote = described_class.new(id: 1, content: [paragraph])

      expect(endnote.content?).to be true
    end

    it 'returns false when endnote has no content' do
      endnote = described_class.new(id: 1)

      expect(endnote.content?).to be false
    end

    it 'returns false when content is nil' do
      endnote = described_class.new(id: 1, content: nil)

      expect(endnote.content?).to be false
    end
  end

  describe '#content' do
    it 'adds a paragraph to the endnote content' do
      endnote = described_class.new(id: 1)
      paragraph = Uniword::Wordprocessingml::Paragraph.new

      endnote.content << paragraph

      expect(endnote.content).to include(paragraph)
      expect(endnote.content.size).to eq(1)
    end

    it 'adds multiple paragraphs' do
      endnote = described_class.new(id: 1)
      p1 = Uniword::Wordprocessingml::Paragraph.new
      p2 = Uniword::Wordprocessingml::Paragraph.new

      endnote.content << p1
      endnote.content << p2

      expect(endnote.content.size).to eq(2)
      expect(endnote.content).to eq([p1, p2])
    end
  end

  describe '#text' do
    it 'returns combined text from all paragraphs' do
      p1 = Uniword::Wordprocessingml::Paragraph.new
      p1.runs << Uniword::Wordprocessingml::Run.new(text: 'First paragraph')

      p2 = Uniword::Wordprocessingml::Paragraph.new
      p2.runs << Uniword::Wordprocessingml::Run.new(text: 'Second paragraph')

      endnote = described_class.new(id: 1, content: [p1, p2])

      expect(endnote.text).to eq("First paragraph\nSecond paragraph")
    end

    it 'returns empty string for endnote without content' do
      endnote = described_class.new(id: 1)

      expect(endnote.text).to eq('')
    end
  end

  describe '#to_h' do
    it 'returns hash representation' do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      endnote = described_class.new(id: 1, content: [paragraph])

      hash = endnote.to_h

      expect(hash).to be_a(Hash)
      expect(hash[:id]).to eq(1)
      expect(hash[:content]).to eq([paragraph])
    end
  end

  describe 'attribute accessors' do
    it 'allows modification of id' do
      endnote = described_class.new(id: 1)
      endnote.id = 2

      expect(endnote.id).to eq(2)
    end

    it 'allows modification of content' do
      endnote = described_class.new(id: 1)
      new_content = [Uniword::Wordprocessingml::Paragraph.new]
      endnote.content = new_content

      expect(endnote.content).to eq(new_content)
    end
  end
end
