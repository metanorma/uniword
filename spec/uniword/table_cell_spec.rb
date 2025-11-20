# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::TableCell do
  let(:paragraph1) { Uniword::Paragraph.new }
  let(:paragraph2) { Uniword::Paragraph.new }

  before do
    paragraph1.add_text('First paragraph')
    paragraph2.add_text('Second paragraph')
  end

  describe '#initialize' do
    it 'creates a cell with no paragraphs' do
      cell = described_class.new
      expect(cell.paragraphs).to eq([])
    end

    it 'creates a cell with width' do
      cell = described_class.new(width: '200')
      expect(cell.width).to eq('200')
    end

    it 'creates a cell with background color' do
      cell = described_class.new(background_color: 'FFFF00')
      expect(cell.background_color).to eq('FFFF00')
    end

    it 'creates a cell with vertical alignment' do
      cell = described_class.new(vertical_alignment: 'center')
      expect(cell.vertical_alignment).to eq('center')
    end

    it 'defaults colspan to 1' do
      cell = described_class.new
      expect(cell.colspan).to eq(1)
    end

    it 'defaults rowspan to 1' do
      cell = described_class.new
      expect(cell.rowspan).to eq(1)
    end
  end

  describe '#accept' do
    it 'accepts a visitor' do
      cell = described_class.new
      visitor = double('visitor')

      expect(visitor).to receive(:visit_table_cell).with(cell)
      cell.accept(visitor)
    end
  end

  describe '#text' do
    it 'returns empty string for cell with no paragraphs' do
      cell = described_class.new
      expect(cell.text).to eq('')
    end

    it 'returns text from a single paragraph' do
      cell = described_class.new(paragraphs: [paragraph1])
      expect(cell.text).to eq('First paragraph')
    end

    it 'concatenates text from multiple paragraphs with newlines' do
      cell = described_class.new(paragraphs: [paragraph1, paragraph2])
      expect(cell.text).to eq("First paragraph\nSecond paragraph")
    end
  end

  describe '#add_paragraph' do
    let(:cell) { described_class.new }

    it 'adds a paragraph to the cell' do
      cell.add_paragraph(paragraph1)
      expect(cell.paragraphs).to include(paragraph1)
    end

    it 'adds multiple paragraphs' do
      cell.add_paragraph(paragraph1)
      cell.add_paragraph(paragraph2)
      expect(cell.paragraphs).to eq([paragraph1, paragraph2])
    end

    it 'raises error for non-Paragraph objects' do
      expect { cell.add_paragraph('not a paragraph') }
        .to raise_error(ArgumentError, /must be a Paragraph instance/)
    end

    it 'returns the updated paragraphs array' do
      result = cell.add_paragraph(paragraph1)
      expect(result).to be_an(Array)
      expect(result).to include(paragraph1)
    end
  end

  describe '#add_text' do
    let(:cell) { described_class.new }

    it 'creates and adds a paragraph with text' do
      cell.add_text('Test text')
      expect(cell.paragraphs.size).to eq(1)
      expect(cell.paragraphs.first.text).to eq('Test text')
    end

    it 'creates and adds a paragraph with properties' do
      props = Uniword::Properties::ParagraphProperties.new(alignment: 'center')
      cell.add_text('Centered', properties: props)
      expect(cell.paragraphs.first.properties).to eq(props)
    end

    it 'returns self for method chaining' do
      result = cell.add_text('Test')
      expect(result).to be(cell)
      expect(cell.paragraphs.last.text).to eq('Test')
    end
  end

  describe '#empty?' do
    it 'returns true for cell with no paragraphs' do
      cell = described_class.new
      expect(cell.empty?).to be true
    end

    it 'returns true for cell with empty paragraphs' do
      empty_para = Uniword::Paragraph.new
      cell = described_class.new(paragraphs: [empty_para])
      expect(cell.empty?).to be true
    end

    it 'returns false for cell with text' do
      cell = described_class.new(paragraphs: [paragraph1])
      expect(cell.empty?).to be false
    end
  end

  describe '#paragraph_count' do
    it 'returns 0 for cell with no paragraphs' do
      cell = described_class.new
      expect(cell.paragraph_count).to eq(0)
    end

    it 'returns correct count for multiple paragraphs' do
      cell = described_class.new(paragraphs: [paragraph1, paragraph2])
      expect(cell.paragraph_count).to eq(2)
    end
  end

  describe 'inheritance' do
    it 'inherits from Element' do
      expect(described_class.ancestors).to include(Uniword::Element)
    end

    it 'is not abstract' do
      expect(described_class.abstract?).to be false
    end
  end
end
