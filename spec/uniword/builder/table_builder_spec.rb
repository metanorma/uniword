# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe Uniword::Builder::TableBuilder do
  describe '#initialize' do
    it 'creates a builder with a new Table model' do
      builder = described_class.new
      expect(builder.model).to be_a(Uniword::Wordprocessingml::Table)
    end
  end

  describe '#row' do
    it 'creates and adds a row' do
      builder = described_class.new
      builder.row do |r|
        r.cell(text: 'Cell 1')
        r.cell(text: 'Cell 2')
      end
      expect(builder.model.rows.size).to eq(1)
      expect(builder.model.rows.first.cells.size).to eq(2)
    end

    it 'adds multiple rows' do
      builder = described_class.new
      builder.row { |r| r.cell(text: 'R1') }
      builder.row { |r| r.cell(text: 'R2') }
      expect(builder.model.rows.size).to eq(2)
    end
  end

  describe '#build' do
    it 'returns the underlying Table model' do
      builder = described_class.new
      expect(builder.build).to be_a(Uniword::Wordprocessingml::Table)
    end
  end
end

RSpec.describe Uniword::Builder::TableRowBuilder do
  describe '#cell' do
    it 'creates a cell with text' do
      builder = described_class.new
      builder.cell(text: 'Hello')
      expect(builder.model.cells.size).to eq(1)
      expect(builder.model.cells.first.text).to eq('Hello')
    end

    it 'creates a cell with block configuration' do
      builder = described_class.new
      builder.cell(text: 'Styled') do |c|
        c.shading(fill: '4472C4')
      end
      expect(builder.model.cells.size).to eq(1)
      expect(builder.model.cells.first.properties.shading).not_to be_nil
    end
  end
end

RSpec.describe Uniword::Builder::TableCellBuilder do
  describe '#<< operator' do
    it 'appends a String as a Paragraph' do
      builder = described_class.new
      builder << 'Cell content'
      expect(builder.model.paragraphs.size).to eq(1)
      expect(builder.model.paragraphs.first.text).to eq('Cell content')
    end

    it 'appends a Paragraph object' do
      builder = described_class.new
      para = Uniword::Wordprocessingml::Paragraph.new
      builder << para
      expect(builder.model.paragraphs).to include(para)
    end
  end

  describe '#shading' do
    it 'sets cell shading' do
      builder = described_class.new
      builder.shading(fill: 'FF0000')
      expect(builder.model.properties.shading).not_to be_nil
    end
  end
end
