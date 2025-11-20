# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Builder do
  describe '#initialize' do
    it 'creates a new document by default' do
      builder = described_class.new
      expect(builder.document).to be_a(Uniword::Document)
    end

    it 'accepts an existing document' do
      doc = Uniword::Document.new
      builder = described_class.new(doc)
      expect(builder.document).to eq(doc)
    end
  end

  describe '#add_paragraph' do
    let(:builder) { described_class.new }

    it 'adds a paragraph with text' do
      builder.add_paragraph('Hello World')
      expect(builder.document.paragraphs.count).to eq(1)
      expect(builder.document.paragraphs.first.text).to eq('Hello World')
    end

    it 'returns self for chaining' do
      result = builder.add_paragraph('Test')
      expect(result).to eq(builder)
    end

    it 'adds paragraph with style' do
      builder.add_paragraph('Title', style: 'Heading1')
      para = builder.document.paragraphs.first
      expect(para.style_id).to eq('Heading1')
    end

    it 'adds paragraph with alignment' do
      builder.add_paragraph('Centered', alignment: 'center')
      para = builder.document.paragraphs.first
      expect(para.alignment).to eq('center')
    end

    it 'adds paragraph with bold text' do
      builder.add_paragraph('Bold', bold: true)
      para = builder.document.paragraphs.first
      expect(para.runs.first.bold?).to be true
    end

    it 'adds paragraph with italic text' do
      builder.add_paragraph('Italic', italic: true)
      para = builder.document.paragraphs.first
      expect(para.runs.first.italic?).to be true
    end

    it 'supports method chaining' do
      builder
        .add_paragraph('First')
        .add_paragraph('Second')
        .add_paragraph('Third')

      expect(builder.document.paragraphs.count).to eq(3)
    end
  end

  describe '#add_heading' do
    let(:builder) { described_class.new }

    it 'adds a heading with default level 1' do
      builder.add_heading('Title')
      para = builder.document.paragraphs.first
      expect(para.style_id).to eq('Heading1')
    end

    it 'adds a heading with custom level' do
      builder.add_heading('Subtitle', level: 2)
      para = builder.document.paragraphs.first
      expect(para.style_id).to eq('Heading2')
    end

    it 'adds a heading with alignment' do
      builder.add_heading('Centered Title', level: 1, alignment: 'center')
      para = builder.document.paragraphs.first
      expect(para.alignment).to eq('center')
    end
  end

  describe '#add_blank_line' do
    let(:builder) { described_class.new }

    it 'adds an empty paragraph' do
      builder.add_blank_line
      expect(builder.document.paragraphs.count).to eq(1)
      expect(builder.document.paragraphs.first.text).to eq('')
    end
  end

  describe '#add_table' do
    let(:builder) { described_class.new }

    it 'adds a table with rows and cells' do
      builder.add_table do
        row do
          cell 'A1'
          cell 'B1'
        end
        row do
          cell 'A2'
          cell 'B2'
        end
      end

      tables = builder.document.tables
      expect(tables.count).to eq(1)
      expect(tables.first.row_count).to eq(2)
      expect(tables.first.rows.first.cell_count).to eq(2)
    end

    it 'supports cell formatting' do
      builder.add_table do
        row do
          cell 'Bold', bold: true
          cell 'Italic', italic: true
        end
      end

      table = builder.document.tables.first
      first_cell = table.rows.first.cells.first
      expect(first_cell.paragraphs.first.runs.first.bold?).to be true
    end

    it 'returns self for chaining' do
      result = builder.add_table do
        row do
          cell 'Data'
        end
      end
      expect(result).to eq(builder)
    end
  end

  describe '#build' do
    let(:builder) { described_class.new }

    it 'returns the constructed document' do
      doc = builder
        .add_paragraph('Test')
        .build

      expect(doc).to be_a(Uniword::Document)
      expect(doc.paragraphs.count).to eq(1)
    end
  end

  describe 'complex document building' do
    it 'builds a document with mixed content' do
      doc = Uniword::Builder.new
        .add_heading('Document Title', level: 1)
        .add_blank_line
        .add_paragraph('Introduction paragraph with ', bold: false)
        .add_paragraph('A paragraph with bold text', bold: true)
        .add_blank_line
        .add_heading('Section 1', level: 2)
        .add_paragraph('Section content')
        .add_table do
          row do
            cell 'Header 1', bold: true
            cell 'Header 2', bold: true
          end
          row do
            cell 'Data 1'
            cell 'Data 2'
          end
        end
        .build

      expect(doc.paragraphs.count).to eq(7)  # Headings and paragraphs
      expect(doc.tables.count).to eq(1)
      expect(doc.paragraphs.first.style_id).to eq('Heading1')
    end
  end
end