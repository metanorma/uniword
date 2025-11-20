# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Transformation::Transformer do
  let(:transformer) { described_class.new }

  describe '#initialize' do
    it 'creates a new transformer with registered rules' do
      expect(transformer).to be_a(described_class)
    end
  end

  describe '#transform' do
    let(:source_doc) do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Hello World', bold: true)
      doc.add_element(para)
      doc
    end

    context 'with explicit parameters' do
      it 'transforms DOCX model to MHTML model' do
        result = transformer.transform(
          source: source_doc,
          source_format: :docx,
          target_format: :mhtml
        )

        expect(result).to be_a(Uniword::Document)
        expect(result.paragraphs.count).to eq(1)
        expect(result.paragraphs.first.text).to eq('Hello World')
        expect(result.paragraphs.first.runs.first.bold?).to be true
      end

      it 'transforms MHTML model to DOCX model' do
        result = transformer.transform(
          source: source_doc,
          source_format: :mhtml,
          target_format: :docx
        )

        expect(result).to be_a(Uniword::Document)
        expect(result.paragraphs.count).to eq(1)
        expect(result.paragraphs.first.text).to eq('Hello World')
      end

      it 'requires source parameter' do
        expect {
          transformer.transform(
            source: nil,
            source_format: :docx,
            target_format: :mhtml
          )
        }.to raise_error(ArgumentError, /Source must be a Document/)
      end

      it 'requires valid source_format' do
        expect {
          transformer.transform(
            source: source_doc,
            source_format: :invalid,
            target_format: :mhtml
          )
        }.to raise_error(ArgumentError, /Source format must be/)
      end

      it 'requires valid target_format' do
        expect {
          transformer.transform(
            source: source_doc,
            source_format: :docx,
            target_format: :invalid
          )
        }.to raise_error(ArgumentError, /Target format must be/)
      end
    end

    context 'with complex document' do
      let(:complex_doc) do
        doc = Uniword::Document.new

        # Add paragraph with formatting
        para1 = Uniword::Paragraph.new
        para1.add_text('Bold text', bold: true)
        para1.add_text(' and italic text', italic: true)
        para1.alignment = 'center'
        doc.add_element(para1)

        # Add table
        table = Uniword::Table.new
        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        cell.add_text('Cell content')
        row.add_cell(cell)
        table.add_row(row)
        doc.add_element(table)

        doc
      end

      it 'transforms all elements' do
        result = transformer.transform(
          source: complex_doc,
          source_format: :docx,
          target_format: :mhtml
        )

        expect(result.paragraphs.count).to eq(1)
        expect(result.tables.count).to eq(1)
        expect(result.paragraphs.first.text).to include('Bold text')
        expect(result.tables.first.rows.count).to eq(1)
      end

      it 'preserves text content' do
        result = transformer.transform(
          source: complex_doc,
          source_format: :docx,
          target_format: :mhtml
        )

        expect(result.text).to eq(complex_doc.text)
      end

      it 'preserves formatting' do
        result = transformer.transform(
          source: complex_doc,
          source_format: :docx,
          target_format: :mhtml
        )

        para = result.paragraphs.first
        expect(para.alignment).to eq('center')
        expect(para.runs.first.bold?).to be true
        expect(para.runs.last.italic?).to be true
      end
    end
  end

  describe '#docx_to_mhtml' do
    it 'explicitly names the transformation direction' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Test')
      doc.add_element(para)

      result = transformer.docx_to_mhtml(doc)

      expect(result).to be_a(Uniword::Document)
      expect(result.paragraphs.first.text).to eq('Test')
    end
  end

  describe '#mhtml_to_docx' do
    it 'explicitly names the transformation direction' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Test')
      doc.add_element(para)

      result = transformer.mhtml_to_docx(doc)

      expect(result).to be_a(Uniword::Document)
      expect(result.paragraphs.first.text).to eq('Test')
    end
  end

  describe '#register_rule' do
    it 'allows registering custom transformation rules' do
      custom_rule = double('CustomRule')
      allow(custom_rule).to receive(:is_a?).with(Uniword::Transformation::TransformationRule).and_return(true)

      expect { transformer.register_rule(custom_rule) }.not_to raise_error
    end
  end
end