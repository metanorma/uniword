# frozen_string_literal: true

require 'spec_helper'

# Helper method to create a table cell with text
def create_row_text_cell(text)
  Uniword::Wordprocessingml::TableCell.new.tap do |cell|
    cell.paragraphs << Uniword::Wordprocessingml::Paragraph.new.tap { |p| p.add_text(text) }
  end
end

RSpec.describe Uniword::Wordprocessingml::TableRow do
  let(:cell1) { create_row_text_cell('Cell 1') }
  let(:cell2) { create_row_text_cell('Cell 2') }

  describe '#initialize' do
    it 'creates a row with no cells' do
      row = described_class.new
      expect(row.cells).to eq([])
    end

    it 'creates a row with properties' do
      props = Uniword::Wordprocessingml::TableRowProperties.new
      row = described_class.new(properties: props)
      expect(row.properties).to eq(props)
    end
  end

  describe '#cells' do
    let(:row) { described_class.new }

    it 'adds a cell to the row' do
      row.cells << cell1
      expect(row.cells).to include(cell1)
    end

    it 'adds multiple cells' do
      row.cells << cell1
      row.cells << cell2
      expect(row.cells).to eq([cell1, cell2])
    end

    it 'returns the cells collection' do
      row.cells << cell1
      expect(row.cells.count).to eq(1)
      expect(row.cells.first).to be_a(Uniword::Wordprocessingml::TableCell)
    end
  end

  describe '#cell_count' do
    it 'returns 0 for row with no cells' do
      row = described_class.new
      expect(row.cells.count).to eq(0)
    end

    it 'returns correct count for multiple cells' do
      row = described_class.new(cells: [cell1, cell2])
      expect(row.cells.count).to eq(2)
    end
  end

  describe '#empty?' do
    it 'returns true for row with no cells' do
      row = described_class.new
      expect(row.cells.empty?).to be true
    end

    it 'returns true for row with empty cells' do
      empty_cell = Uniword::Wordprocessingml::TableCell.new
      row = described_class.new(cells: [empty_cell])
      expect(row.cells.first.paragraphs.empty?).to be true
    end

    it 'returns false for row with text' do
      row = described_class.new(cells: [cell1])
      expect(row.cells.empty?).to be false
    end
  end

  describe 'inheritance' do
    it 'inherits from Lutaml::Model::Serializable' do
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end
  end
end
