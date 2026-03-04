# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'zip'

RSpec.describe 'DOCX Generation Integration' do
  let(:output_file) { Tempfile.new(['test_output', '.docx']) }

  after do
    output_file.close
    output_file.unlink
  end

  describe 'generating a minimal DOCX file' do
    it 'creates a valid DOCX file structure' do
      # Create a document
      doc = Uniword::Document.new
      paragraph = Uniword::Paragraph.new
      paragraph.add_text('Hello, World!')
      doc.add_element(paragraph)

      # Serialize to XML
      serializer = Uniword::Serialization::OoxmlSerializer.new
      xml = serializer.serialize(doc)

      # Package into DOCX
      Uniword::Ooxml::DocxPackage.to_file(doc, output_file.path)

      # Verify file exists and is a valid ZIP
      expect(File.exist?(output_file.path)).to be true
      expect(File.size(output_file.path)).to be > 0

      # Verify ZIP structure
      Zip::File.open(output_file.path) do |zip_file|
        # Check required files exist
        expect(zip_file.find_entry('[Content_Types].xml')).not_to be_nil
        expect(zip_file.find_entry('_rels/.rels')).not_to be_nil
        expect(zip_file.find_entry('word/document.xml')).not_to be_nil
        expect(zip_file.find_entry('word/_rels/document.xml.rels')).not_to be_nil

        # Verify document.xml contains our text
        doc_xml = zip_file.read('word/document.xml')
        expect(doc_xml).to include('Hello, World!')
        expect(doc_xml).to include('<w:document')
        expect(doc_xml).to include('<w:body>')
        expect(doc_xml).to include('<w:p>')
        expect(doc_xml).to include('<w:r>')
        expect(doc_xml).to include('<w:t>')
      end
    end

    it 'handles multiple paragraphs' do
      # Create a document with multiple paragraphs
      doc = Uniword::Document.new

      paragraph1 = Uniword::Paragraph.new
      paragraph1.add_text('First paragraph')
      doc.add_element(paragraph1)

      paragraph2 = Uniword::Paragraph.new
      paragraph2.add_text('Second paragraph')
      doc.add_element(paragraph2)

      # Serialize and package
      serializer = Uniword::Serialization::OoxmlSerializer.new
      xml = serializer.serialize(doc)

      Uniword::Ooxml::DocxPackage.to_file(doc, output_file.path)

      # Verify content
      Zip::File.open(output_file.path) do |zip_file|
        doc_xml = zip_file.read('word/document.xml')
        expect(doc_xml).to include('First paragraph')
        expect(doc_xml).to include('Second paragraph')
        # Should have two <w:p> tags
        expect(doc_xml.scan('<w:p>').count).to eq(2)
      end
    end

    it 'handles text with whitespace preservation' do
      doc = Uniword::Document.new
      paragraph = Uniword::Paragraph.new
      paragraph.add_text('  Text with spaces  ')
      doc.add_element(paragraph)

      serializer = Uniword::Serialization::OoxmlSerializer.new
      xml = serializer.serialize(doc)

      Uniword::Ooxml::DocxPackage.to_file(doc, output_file.path)

      Zip::File.open(output_file.path) do |zip_file|
        doc_xml = zip_file.read('word/document.xml')
        # Should include xml:space="preserve" for whitespace preservation
        expect(doc_xml).to include('xml:space="preserve"')
        expect(doc_xml).to include('  Text with spaces  ')
      end
    end

    describe 'formatted text generation' do
      it 'generates DOCX with bold and italic text' do
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new

        # Bold text
        run1 = Uniword::Run.new(text: 'Bold ')
        run1.properties = Uniword::Wordprocessingml::RunProperties.new(bold: true)
        para.add_run(run1)

        # Italic text
        run2 = Uniword::Run.new(text: 'Italic')
        run2.properties = Uniword::Wordprocessingml::RunProperties.new(italic: true)
        para.add_run(run2)

        doc.add_element(para)

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:b/>')
        expect(xml).to include('<w:i/>')
        expect(xml).to include('Bold ')
        expect(xml).to include('Italic')
      end

      it 'generates DOCX with font size and color' do
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new

        run = Uniword::Run.new(text: 'Colored Text')
        run.properties = Uniword::Wordprocessingml::RunProperties.new(
          size: 28, # 14pt in half-points
          color: 'FF0000' # Red
        )
        para.add_run(run)
        doc.add_element(para)

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:sz w:val="28"/>')
        expect(xml).to include('<w:color w:val="FF0000"/>')
      end

      it 'generates DOCX with underline and strike-through' do
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new

        run = Uniword::Run.new(text: 'Formatted')
        run.properties = Uniword::Wordprocessingml::RunProperties.new(
          underline: 'single',
          strike: true
        )
        para.add_run(run)
        doc.add_element(para)

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:u w:val="single"/>')
        expect(xml).to include('<w:strike/>')
      end
    end

    describe 'paragraph formatting' do
      it 'generates DOCX with paragraph alignment' do
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new
        para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
          alignment: 'center'
        )
        para.add_text('Centered Text')
        doc.add_element(para)

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:jc w:val="center"/>')
      end

      it 'generates DOCX with paragraph spacing' do
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new
        para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
          spacing_before: 240,
          spacing_after: 120
        )
        para.add_text('Spaced Paragraph')
        doc.add_element(para)

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:spacing w:before="240" w:after="120"/>')
      end
    end

    describe 'table generation' do
      it 'generates DOCX with a simple table' do
        doc = Uniword::Document.new

        table = Uniword::Table.new
        row = Uniword::TableRow.new

        cell1 = Uniword::TableCell.new
        cell1.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell 1') }
        row.cells << cell1

        cell2 = Uniword::TableCell.new
        cell2.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell 2') }
        row.cells << cell2

        table.rows << row
        doc.add_element(table)

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:tbl>')
        expect(xml).to include('<w:tr>')
        expect(xml).to include('<w:tc>')
        expect(xml).to include('Cell 1')
        expect(xml).to include('Cell 2')
      end

      it 'generates DOCX with table containing multiple rows' do
        doc = Uniword::Document.new

        table = Uniword::Table.new

        # Header row
        header_row = Uniword::TableRow.new
        header_row.properties = Uniword::TableRowProperties.new(table_header: true)
        header_row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Header 1') } }
        header_row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Header 2') } }
        table.rows << header_row

        # Data row
        data_row = Uniword::TableRow.new
        data_row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Data 1') } }
        data_row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Data 2') } }
        table.rows << data_row

        doc.add_element(table)

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:tblHeader/>')
        expect(xml).to include('Header 1')
        expect(xml).to include('Data 1')
      end

      it 'generates DOCX with table properties' do
        doc = Uniword::Document.new

        table = Uniword::Table.new
        table.properties = Uniword::Wordprocessingml::TableProperties.new(
          width: '5000',
          alignment: 'center'
        )

        row = Uniword::TableRow.new
        row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Content') } }
        table.rows << row

        doc.add_element(table)

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:tblW w:w="5000" w:type="dxa"/>')
        expect(xml).to include('<w:jc w:val="center"/>')
      end

      it 'generates DOCX with cell background color' do
        doc = Uniword::Document.new

        table = Uniword::Table.new
        row = Uniword::TableRow.new

        cell = Uniword::TableCell.new
        cell.properties = Uniword::TableCellProperties.new(shading: Uniword::Shading.new(fill: 'FFFF00'))
        cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Highlighted') }
        row.cells << cell

        table.rows << row
        doc.add_element(table)

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:shd')
        expect(xml).to include('FFFF00')
      end
    end

    describe 'mixed content generation' do
      it 'generates DOCX with paragraphs and tables' do
        doc = Uniword::Document.new

        # Add a paragraph
        para1 = Uniword::Paragraph.new
        para1.add_text('Introduction text')
        doc.add_element(para1)

        # Add a table
        table = Uniword::Table.new
        row = Uniword::TableRow.new
        row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Table content') } }
        table.rows << row
        doc.add_element(table)

        # Add another paragraph
        para2 = Uniword::Paragraph.new
        para2.add_text('Conclusion text')
        doc.add_element(para2)

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('Introduction text')
        expect(xml).to include('<w:tbl>')
        expect(xml).to include('Table content')
        expect(xml).to include('Conclusion text')
      end
    end
  end
end
