# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Wordprocessingml::TableCell do
  let(:paragraph1) { Uniword::Wordprocessingml::Paragraph.new.tap { |p| p.add_text('First paragraph') } }
  let(:paragraph2) { Uniword::Wordprocessingml::Paragraph.new.tap { |p| p.add_text('Second paragraph') } }

  describe '#initialize' do
    it 'creates a cell with no paragraphs' do
      cell = described_class.new
      expect(cell.paragraphs).to eq([])
    end

    it 'creates a cell with properties' do
      props = Uniword::Wordprocessingml::TableCellProperties.new
      cell = described_class.new(properties: props)
      expect(cell.properties).to eq(props)
    end
  end

  describe '#paragraphs' do
    let(:cell) { described_class.new }

    it 'adds a paragraph to the cell' do
      cell.paragraphs << paragraph1
      expect(cell.paragraphs).to include(paragraph1)
    end

    it 'adds multiple paragraphs' do
      cell.paragraphs << paragraph1
      cell.paragraphs << paragraph2
      expect(cell.paragraphs).to eq([paragraph1, paragraph2])
    end

    it 'returns the paragraphs collection' do
      cell.paragraphs << paragraph1
      expect(cell.paragraphs.count).to eq(1)
      expect(cell.paragraphs.first).to be_a(Uniword::Wordprocessingml::Paragraph)
    end
  end

  describe '#text' do
    it 'returns empty string for cell with no paragraphs' do
      cell = described_class.new
      expect(cell.paragraphs.map(&:text).join).to eq('')
    end

    it 'returns text from a single paragraph' do
      cell = described_class.new(paragraphs: [paragraph1])
      expect(cell.paragraphs.first.text).to eq('First paragraph')
    end

    it 'concatenates text from multiple paragraphs' do
      cell = described_class.new(paragraphs: [paragraph1, paragraph2])
      expect(cell.paragraphs.map(&:text).join("\n")).to eq("First paragraph\nSecond paragraph")
    end
  end

  describe '#empty?' do
    it 'returns true for cell with no paragraphs' do
      cell = described_class.new
      expect(cell.paragraphs.empty?).to be true
    end

    it 'returns true for cell with empty paragraphs' do
      empty_para = Uniword::Wordprocessingml::Paragraph.new
      cell = described_class.new(paragraphs: [empty_para])
      expect(cell.paragraphs.first.empty?).to be true
    end

    it 'returns false for cell with text' do
      cell = described_class.new(paragraphs: [paragraph1])
      expect(cell.paragraphs.empty?).to be false
    end
  end

  describe '#paragraph_count' do
    it 'returns 0 for cell with no paragraphs' do
      cell = described_class.new
      expect(cell.paragraphs.count).to eq(0)
    end

    it 'returns correct count for multiple paragraphs' do
      cell = described_class.new(paragraphs: [paragraph1, paragraph2])
      expect(cell.paragraphs.count).to eq(2)
    end
  end

  describe 'inheritance' do
    it 'inherits from Lutaml::Model::Serializable' do
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end
  end
end
