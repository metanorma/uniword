# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Ooxml::Schema::ElementSerializer do
  let(:serializer) { described_class.new }

  describe '#initialize' do
    it 'creates serializer with default schema' do
      expect(serializer).to be_a(described_class)
    end

    it 'accepts custom schema' do
      schema = double('OoxmlSchema')
      custom_serializer = described_class.new(schema: schema)
      expect(custom_serializer).to be_a(described_class)
    end
  end

  describe '#serialize' do
    context 'with paragraph element' do
      let(:paragraph) do
        para = Uniword::Paragraph.new
        para.add_text('Hello World')
        para
      end

      it 'serializes paragraph to OOXML XML' do
        xml = serializer.serialize(paragraph)

        expect(xml).to include('<w:p')
        expect(xml).to include('</w:p>')
      end

      it 'includes paragraph content' do
        xml = serializer.serialize(paragraph)

        expect(xml).to include('Hello World')
      end

      it 'uses schema-defined structure' do
        xml = serializer.serialize(paragraph)

        # Should have run element
        expect(xml).to include('<w:r')

        # Should have text element
        expect(xml).to include('<w:t')
      end
    end

    context 'with formatted paragraph' do
      let(:paragraph) do
        para = Uniword::Paragraph.new
        para.alignment = 'center'
        para.add_text('Centered text', bold: true)
        para
      end

      it 'includes paragraph properties' do
        xml = serializer.serialize(paragraph)

        expect(xml).to include('<w:pPr')
        expect(xml).to include('<w:jc')
      end

      it 'includes run properties' do
        xml = serializer.serialize(paragraph)

        expect(xml).to include('<w:rPr')
        expect(xml).to include('<w:b')
      end
    end

    context 'with table element' do
      let(:table) do
        tbl = Uniword::Table.new
        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell content') }
        row.cells << cell
        tbl.rows << row
        tbl
      end

      it 'serializes table to OOXML XML' do
        xml = serializer.serialize(table)

        expect(xml).to include('<w:tbl')
        expect(xml).to include('</w:tbl>')
      end

      it 'includes table rows' do
        xml = serializer.serialize(table)

        expect(xml).to include('<w:tr')
        expect(xml).to include('</w:tr>')
      end

      it 'includes table cells' do
        xml = serializer.serialize(table)

        expect(xml).to include('<w:tc')
        expect(xml).to include('</w:tc>')
      end

      it 'includes cell content' do
        xml = serializer.serialize(table)

        expect(xml).to include('Cell content')
      end
    end

    context 'with run element' do
      let(:run) do
        r = Uniword::Run.new(text: 'Test text')
        r.bold = true
        r.italic = true
        r
      end

      it 'serializes run to OOXML XML' do
        xml = serializer.serialize(run)

        expect(xml).to include('<w:r')
        expect(xml).to include('</w:r>')
      end

      it 'includes text content' do
        xml = serializer.serialize(run)

        expect(xml).to include('Test text')
      end

      it 'includes formatting' do
        xml = serializer.serialize(run)

        expect(xml).to include('<w:rPr')
        expect(xml).to include('<w:b')
        expect(xml).to include('<w:i')
      end
    end

    context 'with options' do
      let(:paragraph) do
        para = Uniword::Paragraph.new
        para.add_text('Test')
        para
      end

      it 'supports pretty print option' do
        xml = serializer.serialize(paragraph, pretty: true)

        expect(xml).to be_a(String)
        # Pretty print adds newlines and indentation
        expect(xml.scan("\n").count).to be > 0
      end

      it 'supports standalone option' do
        xml_with = serializer.serialize(paragraph, standalone: true)
        xml_without = serializer.serialize(paragraph, standalone: false)

        expect(xml_with).to include('<?xml')
        expect(xml_without).not_to include('<?xml')
      end
    end

    context 'with invalid input' do
      it 'raises error for non-element' do
        expect do
          serializer.serialize('not an element')
        end.to raise_error(ArgumentError, /must be a Uniword::Element/)
      end

      it 'raises error for nil' do
        expect do
          serializer.serialize(nil)
        end.to raise_error(ArgumentError)
      end
    end
  end
end
