# frozen_string_literal: true

require 'spec_helper'
require 'uniword/footnote'

RSpec.describe Uniword::Footnote do
  describe '#initialize' do
    it 'creates a footnote with id and content' do
      paragraph = Uniword::Paragraph.new
      footnote = described_class.new(id: 1, content: [paragraph])

      expect(footnote.id).to eq(1)
      expect(footnote.content).to eq([paragraph])
    end

    it 'creates a footnote with default empty content' do
      footnote = described_class.new(id: 2)

      expect(footnote.id).to eq(2)
      expect(footnote.content).to eq([])
    end

    it 'accepts string id' do
      footnote = described_class.new(id: 'fn1')

      expect(footnote.id).to eq('fn1')
    end
  end

  describe '#content?' do
    it 'returns true when footnote has content' do
      paragraph = Uniword::Paragraph.new
      footnote = described_class.new(id: 1, content: [paragraph])

      expect(footnote.content?).to be true
    end

    it 'returns false when footnote has no content' do
      footnote = described_class.new(id: 1)

      expect(footnote.content?).to be false
    end

    it 'returns false when content is nil' do
      footnote = described_class.new(id: 1, content: nil)

      expect(footnote.content?).to be false
    end
  end

  describe '#add_paragraph' do
    it 'adds a paragraph to the footnote content' do
      footnote = described_class.new(id: 1)
      paragraph = Uniword::Paragraph.new

      footnote.add_paragraph(paragraph)

      expect(footnote.content).to include(paragraph)
      expect(footnote.content.size).to eq(1)
    end

    it 'adds multiple paragraphs' do
      footnote = described_class.new(id: 1)
      p1 = Uniword::Paragraph.new
      p2 = Uniword::Paragraph.new

      footnote.add_paragraph(p1)
      footnote.add_paragraph(p2)

      expect(footnote.content.size).to eq(2)
      expect(footnote.content).to eq([p1, p2])
    end
  end

  describe '#text' do
    it 'returns combined text from all paragraphs' do
      p1 = Uniword::Paragraph.new
      p1.runs << Uniword::Run.new(text: 'First paragraph')

      p2 = Uniword::Paragraph.new
      p2.runs << Uniword::Run.new(text: 'Second paragraph')

      footnote = described_class.new(id: 1, content: [p1, p2])

      expect(footnote.text).to eq("First paragraph\nSecond paragraph")
    end

    it 'returns empty string for footnote without content' do
      footnote = described_class.new(id: 1)

      expect(footnote.text).to eq('')
    end
  end

  describe '#to_h' do
    it 'returns hash representation' do
      paragraph = Uniword::Paragraph.new
      footnote = described_class.new(id: 1, content: [paragraph])

      hash = footnote.to_h

      expect(hash).to be_a(Hash)
      expect(hash[:id]).to eq(1)
      expect(hash[:content]).to eq([paragraph])
    end
  end

  describe 'attribute accessors' do
    it 'allows modification of id' do
      footnote = described_class.new(id: 1)
      footnote.id = 2

      expect(footnote.id).to eq(2)
    end

    it 'allows modification of content' do
      footnote = described_class.new(id: 1)
      new_content = [Uniword::Paragraph.new]
      footnote.content = new_content

      expect(footnote.content).to eq(new_content)
    end
  end
end
