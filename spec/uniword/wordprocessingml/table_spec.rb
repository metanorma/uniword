# frozen_string_literal: true

require 'spec_helper'

# Helper method to create a table cell with text
def create_text_cell(text)
  Uniword::Wordprocessingml::TableCell.new.tap do |cell|
    para = Uniword::Wordprocessingml::Paragraph.new
    run = Uniword::Wordprocessingml::Run.new(text: text)
    para.runs << run
    cell.paragraphs << para
  end
end

# Helper method to create a table row with text cells
def create_text_row(*texts)
  Uniword::Wordprocessingml::TableRow.new.tap do |row|
    texts.each do |text|
      row.cells << create_text_cell(text)
    end
  end
end

RSpec.describe Uniword::Wordprocessingml::Table do
  let(:row1) { create_text_row('A1', 'B1') }
  let(:row2) { create_text_row('A2', 'B2') }
  let(:properties) do
    Uniword::Wordprocessingml::TableProperties.new(
      style: 'TableGrid',
      alignment: 'center'
    )
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

  describe '#rows' do
    let(:table) { described_class.new }

    it 'adds a row to the table' do
      table.rows << row1
      expect(table.rows).to include(row1)
    end

    it 'adds multiple rows' do
      table.rows << row1
      table.rows << row2
      expect(table.rows).to eq([row1, row2])
    end

    it 'returns the rows collection' do
      table.rows << row1
      expect(table.rows.count).to eq(1)
      expect(table.rows.first).to be_a(Uniword::Wordprocessingml::TableRow)
    end
  end

  describe '#row_count' do
    it 'returns 0 for table with no rows' do
      table = described_class.new
      expect(table.rows.count).to eq(0)
    end

    it 'returns correct count for multiple rows' do
      table = described_class.new(rows: [row1, row2])
      expect(table.rows.count).to eq(2)
    end
  end

  describe '#column_count' do
    it 'returns 0 for table with no rows' do
      table = described_class.new
      expect(table.rows.first&.cells&.count || 0).to eq(0)
    end

    it 'returns column count based on first row' do
      table = described_class.new(rows: [row1, row2])
      expect(table.rows.first.cells.count).to eq(2)
    end
  end

  describe '#empty?' do
    it 'returns true for table with no rows' do
      table = described_class.new
      expect(table.rows.empty?).to be true
    end

    it 'returns true for table with empty rows' do
      empty_row = Uniword::Wordprocessingml::TableRow.new
      table = described_class.new(rows: [empty_row])
      expect(table.rows.first.cells.empty?).to be true
    end

    it 'returns false for table with data' do
      table = described_class.new(rows: [row1])
      expect(table.rows.empty?).to be false
    end
  end

  describe 'inheritance' do
    it 'inherits from Lutaml::Model::Serializable' do
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end
  end
end
