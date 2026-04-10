# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe Uniword::Ooxml::Schema::ElementSerializer do
  let(:serializer) { described_class.new }

  describe '#initialize' do
    it 'creates serializer with default schema' do
      expect(serializer).to be_a(described_class)
    end
  end

  describe '#serialize' do
    context 'with paragraph element' do
      let(:paragraph) do
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Hello World')
        para.runs << run
        para
      end

      it 'serializes paragraph to OOXML XML' do
        xml = serializer.serialize(paragraph)

        # Accepts either prefixed (<w:p>) or default namespace (<p xmlns="...">)
        expect(xml).to match(/<(?:w:)?p[^>]*>/)
        expect(xml).to match(%r{</(?:w:)?p>})
      end

      it 'includes paragraph content' do
        xml = serializer.serialize(paragraph)

        expect(xml).to include('Hello World')
      end

      it 'uses schema-defined structure' do
        xml = serializer.serialize(paragraph)

        # Should have run element
        expect(xml).to match(/<(?:w:)?r[^>]*>/)

        # Should have text element
        expect(xml).to match(/<(?:w:)?t[^>]*>/)
      end
    end

    context 'with formatted paragraph' do
      let(:paragraph) do
        para = Uniword::Wordprocessingml::Paragraph.new
        para.properties ||= Uniword::Wordprocessingml::ParagraphProperties.new
        para.properties.alignment = Uniword::Properties::Alignment.new(value: 'center')
        run = Uniword::Wordprocessingml::Run.new(text: 'Centered text')
        Uniword::Builder::RunBuilder.new(run).bold
        para.runs << run
        para
      end

      it 'includes paragraph properties' do
        xml = serializer.serialize(paragraph)

        expect(xml).to match(/<(?:w:)?pPr/)
        expect(xml).to match(/<(?:w:)?jc/)
      end

      it 'includes run properties' do
        xml = serializer.serialize(paragraph)

        expect(xml).to match(/<(?:w:)?rPr/)
        expect(xml).to match(/<(?:w:)?b/)
      end
    end

    context 'with table element' do
      let(:table) do
        tbl = Uniword::Wordprocessingml::Table.new
        row = Uniword::Wordprocessingml::TableRow.new
        cell = Uniword::Wordprocessingml::TableCell.new
        cell_para = Uniword::Wordprocessingml::Paragraph.new
        cell_run = Uniword::Wordprocessingml::Run.new(text: 'Cell content')
        cell_para.runs << cell_run
        cell.paragraphs << cell_para
        row.cells << cell
        tbl.rows << row
        tbl
      end

      it 'serializes table to OOXML XML' do
        xml = serializer.serialize(table)

        expect(xml).to match(/<(?:w:)?tbl/)
        expect(xml).to match(%r{</(?:w:)?tbl>})
      end

      it 'includes table rows' do
        xml = serializer.serialize(table)

        expect(xml).to match(/<(?:w:)?tr/)
        expect(xml).to match(%r{</(?:w:)?tr>})
      end

      it 'includes table cells' do
        xml = serializer.serialize(table)

        expect(xml).to match(/<(?:w:)?tc/)
        expect(xml).to match(%r{</(?:w:)?tc>})
      end

      it 'includes cell content' do
        xml = serializer.serialize(table)

        expect(xml).to include('Cell content')
      end
    end

    context 'with run element' do
      let(:run) do
        r = Uniword::Wordprocessingml::Run.new(text: 'Test text')
        Uniword::Builder::RunBuilder.new(r).bold.italic
        r
      end

      it 'serializes run to OOXML XML' do
        xml = serializer.serialize(run)

        expect(xml).to match(/<(?:w:)?r[^>]*>/)
        expect(xml).to match(%r{</(?:w:)?r>})
      end

      it 'includes text content' do
        xml = serializer.serialize(run)

        expect(xml).to include('Test text')
      end

      it 'includes formatting' do
        xml = serializer.serialize(run)

        expect(xml).to match(/<(?:w:)?rPr/)
        expect(xml).to match(/<(?:w:)?b/)
        expect(xml).to match(/<(?:w:)?i/)
      end
    end

    context 'with options' do
      let(:paragraph) do
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Test')
        para.runs << run
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
        end.to raise_error(ArgumentError, /must respond to #to_xml/)
      end

      it 'raises error for nil' do
        expect do
          serializer.serialize(nil)
        end.to raise_error(ArgumentError)
      end
    end
  end
end
