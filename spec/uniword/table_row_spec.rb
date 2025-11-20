# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::TableRow do
  let(:cell1) { Uniword::TableCell.new }
  let(:cell2) { Uniword::TableCell.new }

  before do
    cell1.add_text('Cell 1')
    cell2.add_text('Cell 2')
  end

  describe '#initialize' do
    it 'creates a row with no cells' do
      row = described_class.new
      expect(row.cells).to eq([])
    end

    it 'creates a row with height' do
      row = described_class.new(height: '500')
      expect(row.height).to eq('500')
    end

    it 'defaults header to false' do
      row = described_class.new
      expect(row.header).to be false
    end

    it 'creates a header row' do
      row = described_class.new(header: true)
      expect(row.header).to be true
    end

    it 'defaults allow_break to true' do
      row = described_class.new
      expect(row.allow_break).to be true
    end
  end

  describe '#accept' do
    it 'accepts a visitor' do
      row = described_class.new
      visitor = double('visitor')

      expect(visitor).to receive(:visit_table_row).with(row)
      row.accept(visitor)
    end
  end

  describe '#add_cell' do
    let(:row) { described_class.new }

    it 'adds a cell to the row' do
      row.add_cell(cell1)
      expect(row.cells).to include(cell1)
    end

    it 'adds multiple cells' do
      row.add_cell(cell1)
      row.add_cell(cell2)
      expect(row.cells).to eq([cell1, cell2])
    end

    it 'accepts string and creates cell with text' do
      cell = row.add_cell('Test text')
      expect(cell).to be_a(Uniword::TableCell)
      expect(cell.text).to eq('Test text')
    end

    it 'returns the added cell for method chaining' do
      result = row.add_cell(cell1)
      expect(result).to be(cell1)
      expect(row.cells).to include(cell1)
    end
  end

  describe '#add_text_cell' do
    let(:row) { described_class.new }

    it 'creates and adds a cell with text' do
      row.add_text_cell('Test cell')
      expect(row.cells.size).to eq(1)
      expect(row.cells.first.text).to eq('Test cell')
    end

    it 'creates and adds a cell with properties' do
      row.add_text_cell('Test', properties: { width: '100' })
      expect(row.cells.first.width).to eq('100')
    end

    it 'returns the created cell' do
      cell = row.add_text_cell('Test')
      expect(cell).to be_a(Uniword::TableCell)
      expect(cell.text).to eq('Test')
    end
  end

  describe '#cell_count' do
    it 'returns 0 for row with no cells' do
      row = described_class.new
      expect(row.cell_count).to eq(0)
    end

    it 'returns correct count for multiple cells' do
      row = described_class.new(cells: [cell1, cell2])
      expect(row.cell_count).to eq(2)
    end
  end

  describe '#empty?' do
    it 'returns true for row with no cells' do
      row = described_class.new
      expect(row.empty?).to be true
    end

    it 'returns true for row with empty cells' do
      empty_cell = Uniword::TableCell.new
      row = described_class.new(cells: [empty_cell])
      expect(row.empty?).to be true
    end

    it 'returns false for row with text' do
      row = described_class.new(cells: [cell1])
      expect(row.empty?).to be false
    end
  end

  describe '#header?' do
    it 'returns false for non-header row' do
      row = described_class.new
      expect(row.header?).to be false
    end

    it 'returns true for header row' do
      row = described_class.new(header: true)
      expect(row.header?).to be true
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
