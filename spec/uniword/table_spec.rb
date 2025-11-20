# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Table do
  let(:row1) { Uniword::TableRow.new }
  let(:row2) { Uniword::TableRow.new }
  let(:properties) do
    Uniword::Properties::TableProperties.new(
      style: 'TableGrid',
      alignment: 'center'
    )
  end

  before do
    row1.add_text_cell('A1')
    row1.add_text_cell('B1')
    row2.add_text_cell('A2')
    row2.add_text_cell('B2')
  end

  describe '#initialize' do
    it 'creates a table with no rows' do
      table = described_class.new
      expect(table.rows).to eq([])
    end

    it 'creates a table with properties' do
      table = described_class.new(properties: properties)
      expect(table.properties).to eq(properties)
    end
  end

  describe '#accept' do
    it 'accepts a visitor' do
      table = described_class.new
      visitor = double('visitor')

      expect(visitor).to receive(:visit_table).with(table)
      table.accept(visitor)
    end
  end

  describe '#add_row' do
    let(:table) { described_class.new }

    it 'adds a row to the table' do
      table.add_row(row1)
      expect(table.rows).to include(row1)
    end

    it 'adds multiple rows' do
      table.add_row(row1)
      table.add_row(row2)
      expect(table.rows).to eq([row1, row2])
    end

    it 'raises error for non-TableRow objects' do
      expect { table.add_row('not a row') }
        .to raise_error(ArgumentError, /must be a TableRow instance/)
    end

    it 'returns the added row for method chaining' do
      result = table.add_row(row1)
      expect(result).to be(row1)
      expect(table.rows).to include(row1)
    end
  end

  describe '#add_text_row' do
    let(:table) { described_class.new }

    it 'creates and adds a row with text cells' do
      table.add_text_row(%w[A B C])
      expect(table.rows.size).to eq(1)
      expect(table.rows.first.cell_count).to eq(3)
    end

    it 'creates a header row when specified' do
      table.add_text_row(%w[Header1 Header2], header: true)
      expect(table.rows.first.header?).to be true
    end

    it 'creates a data row by default' do
      table.add_text_row(%w[Data1 Data2])
      expect(table.rows.first.header?).to be false
    end

    it 'returns the created row' do
      row = table.add_text_row(%w[A B])
      expect(row).to be_a(Uniword::TableRow)
    end
  end

  describe '#row_count' do
    it 'returns 0 for table with no rows' do
      table = described_class.new
      expect(table.row_count).to eq(0)
    end

    it 'returns correct count for multiple rows' do
      table = described_class.new(rows: [row1, row2])
      expect(table.row_count).to eq(2)
    end
  end

  describe '#column_count' do
    it 'returns 0 for table with no rows' do
      table = described_class.new
      expect(table.column_count).to eq(0)
    end

    it 'returns column count based on first row' do
      table = described_class.new(rows: [row1, row2])
      expect(table.column_count).to eq(2)
    end
  end

  describe '#empty?' do
    it 'returns true for table with no rows' do
      table = described_class.new
      expect(table.empty?).to be true
    end

    it 'returns true for table with empty rows' do
      empty_row = Uniword::TableRow.new
      table = described_class.new(rows: [empty_row])
      expect(table.empty?).to be true
    end

    it 'returns false for table with data' do
      table = described_class.new(rows: [row1])
      expect(table.empty?).to be false
    end
  end

  describe '#header_rows' do
    it 'returns empty array when no header rows' do
      table = described_class.new(rows: [row1, row2])
      expect(table.header_rows).to eq([])
    end

    it 'returns only header rows' do
      header_row = Uniword::TableRow.new(header: true)
      header_row.add_text_cell('Header')
      table = described_class.new(rows: [header_row, row1, row2])
      expect(table.header_rows).to eq([header_row])
    end
  end

  describe '#data_rows' do
    it 'returns all rows when no headers' do
      table = described_class.new(rows: [row1, row2])
      expect(table.data_rows).to eq([row1, row2])
    end

    it 'returns only data rows' do
      header_row = Uniword::TableRow.new(header: true)
      header_row.add_text_cell('Header')
      table = described_class.new(rows: [header_row, row1, row2])
      expect(table.data_rows).to eq([row1, row2])
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
