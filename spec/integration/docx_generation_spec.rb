# frozen_string_literal: true

require "spec_helper"
require "securerandom"
require "zip"

RSpec.describe "DOCX Generation Integration" do
  describe "generating a minimal DOCX file" do
    it "creates a valid DOCX file structure" do
      output_path = File.join(Dir.tmpdir,
                              "uniword_test_#{SecureRandom.uuid}.docx")
      begin
        # Create a document
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        paragraph = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Hello, World!")
        paragraph.runs << run
        doc.body.paragraphs << paragraph

        # Serialize to XML
        serializer = Uniword::Serialization::OoxmlSerializer.new
        serializer.serialize(doc)

        # Package into DOCX
        Uniword::Docx::Package.to_file(doc, output_path)

        # Verify file exists and is a valid ZIP
        expect(File.exist?(output_path)).to be true
        expect(File.size(output_path)).to be > 0

        # Verify ZIP structure
        Zip::File.open(output_path) do |zip_file|
          # Check required files exist
          expect(zip_file.find_entry("[Content_Types].xml")).not_to be_nil
          expect(zip_file.find_entry("_rels/.rels")).not_to be_nil
          expect(zip_file.find_entry("word/document.xml")).not_to be_nil
          expect(zip_file.find_entry("word/_rels/document.xml.rels")).not_to be_nil

          # Verify document.xml contains our text
          doc_xml = zip_file.read("word/document.xml")
          expect(doc_xml).to include("Hello, World!")
          expect(doc_xml).to include("<w:document")
          expect(doc_xml).to include("<w:body>")
          expect(doc_xml).to include("<w:p ")
          expect(doc_xml).to include("<w:r>")
          expect(doc_xml).to include("<w:t>")
        end
      ensure
        safe_delete(output_path)
      end
    end

    it "handles multiple paragraphs" do
      output_path = File.join(Dir.tmpdir,
                              "uniword_test_#{SecureRandom.uuid}.docx")
      begin
        # Create a document with multiple paragraphs
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        paragraph1 = Uniword::Wordprocessingml::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: "First paragraph")
        paragraph1.runs << run1
        doc.body.paragraphs << paragraph1

        paragraph2 = Uniword::Wordprocessingml::Paragraph.new
        run2 = Uniword::Wordprocessingml::Run.new(text: "Second paragraph")
        paragraph2.runs << run2
        doc.body.paragraphs << paragraph2

        # Serialize and package
        serializer = Uniword::Serialization::OoxmlSerializer.new
        serializer.serialize(doc)

        Uniword::Docx::Package.to_file(doc, output_path)

        # Verify content
        Zip::File.open(output_path) do |zip_file|
          doc_xml = zip_file.read("word/document.xml")
          expect(doc_xml).to include("First paragraph")
          expect(doc_xml).to include("Second paragraph")
          # Should have two <w:p> tags
          expect(doc_xml.scan(/<w:p[ >]/).count).to eq(2)
        end
      ensure
        safe_delete(output_path)
      end
    end

    it "handles text with whitespace preservation" do
      output_path = File.join(Dir.tmpdir,
                              "uniword_test_#{SecureRandom.uuid}.docx")
      begin
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        paragraph = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "  Text with spaces  ")
        paragraph.runs << run
        doc.body.paragraphs << paragraph

        serializer = Uniword::Serialization::OoxmlSerializer.new
        serializer.serialize(doc)

        Uniword::Docx::Package.to_file(doc, output_path)

        Zip::File.open(output_path) do |zip_file|
          doc_xml = zip_file.read("word/document.xml")
          # Should include xml:space="preserve" for whitespace preservation
          expect(doc_xml).to include('xml:space="preserve"')
          expect(doc_xml).to include("  Text with spaces  ")
        end
      ensure
        safe_delete(output_path)
      end
    end

    describe "formatted text generation" do
      it "generates DOCX with bold and italic text" do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new

        # Bold text
        run1 = Uniword::Wordprocessingml::Run.new(text: "Bold ")
        run1.properties = Uniword::Wordprocessingml::RunProperties.new(bold: true)
        para.runs << run1

        # Italic text
        run2 = Uniword::Wordprocessingml::Run.new(text: "Italic")
        run2.properties = Uniword::Wordprocessingml::RunProperties.new(italic: true)
        para.runs << run2

        doc.body.paragraphs << para

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include("<w:b/>")
        expect(xml).to include("<w:i/>")
        expect(xml).to include("Bold ")
        expect(xml).to include("Italic")
      end

      it "generates DOCX with font size and color" do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new

        run = Uniword::Wordprocessingml::Run.new(text: "Colored Text")
        run.properties = Uniword::Wordprocessingml::RunProperties.new(
          size: 28, # 14pt in half-points
          color: "FF0000", # Red
        )
        para.runs << run
        doc.body.paragraphs << para

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:sz w:val="28"/>')
        expect(xml).to include('<w:color w:val="FF0000"/>')
      end

      it "generates DOCX with underline and strike-through" do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new

        run = Uniword::Wordprocessingml::Run.new(text: "Formatted")
        run.properties = Uniword::Wordprocessingml::RunProperties.new(
          underline: "single",
          strike: true,
        )
        para.runs << run
        doc.body.paragraphs << para

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:u w:val="single"/>')
        expect(xml).to include("<w:strike/>")
      end
    end

    describe "paragraph formatting" do
      it "generates DOCX with paragraph alignment" do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
          alignment: "center",
        )
        run = Uniword::Wordprocessingml::Run.new(text: "Centered Text")
        para.runs << run
        doc.body.paragraphs << para

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:jc w:val="center"/>')
      end

      it "generates DOCX with paragraph spacing" do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        para.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
          spacing_before: 240,
          spacing_after: 120,
        )
        run = Uniword::Wordprocessingml::Run.new(text: "Spaced Paragraph")
        para.runs << run
        doc.body.paragraphs << para

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:spacing w:before="240" w:after="120"/>')
      end
    end

    describe "table generation" do
      it "generates DOCX with a simple table" do
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        table = Uniword::Wordprocessingml::Table.new
        row = Uniword::Wordprocessingml::TableRow.new

        cell1 = Uniword::Wordprocessingml::TableCell.new
        cell1_para = Uniword::Wordprocessingml::Paragraph.new
        cell1_run = Uniword::Wordprocessingml::Run.new(text: "Cell 1")
        cell1_para.runs << cell1_run
        cell1.paragraphs << cell1_para
        row.cells << cell1

        cell2 = Uniword::Wordprocessingml::TableCell.new
        cell2_para = Uniword::Wordprocessingml::Paragraph.new
        cell2_run = Uniword::Wordprocessingml::Run.new(text: "Cell 2")
        cell2_para.runs << cell2_run
        cell2.paragraphs << cell2_para
        row.cells << cell2

        table.rows << row
        doc.body.tables << table

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include("<w:tbl>")
        expect(xml).to include("<w:tr>")
        expect(xml).to include("<w:tc>")
        expect(xml).to include("Cell 1")
        expect(xml).to include("Cell 2")
      end

      it "generates DOCX with table containing multiple rows" do
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        table = Uniword::Wordprocessingml::Table.new

        # Header row
        header_row = Uniword::Wordprocessingml::TableRow.new
        header_row.properties = Uniword::Wordprocessingml::TableRowProperties.new(table_header: true)

        header_cell1 = Uniword::Wordprocessingml::TableCell.new
        header_cell1_para = Uniword::Wordprocessingml::Paragraph.new
        header_cell1_run = Uniword::Wordprocessingml::Run.new(text: "Header 1")
        header_cell1_para.runs << header_cell1_run
        header_cell1.paragraphs << header_cell1_para
        header_row.cells << header_cell1

        header_cell2 = Uniword::Wordprocessingml::TableCell.new
        header_cell2_para = Uniword::Wordprocessingml::Paragraph.new
        header_cell2_run = Uniword::Wordprocessingml::Run.new(text: "Header 2")
        header_cell2_para.runs << header_cell2_run
        header_cell2.paragraphs << header_cell2_para
        header_row.cells << header_cell2

        table.rows << header_row

        # Data row
        data_row = Uniword::Wordprocessingml::TableRow.new

        data_cell1 = Uniword::Wordprocessingml::TableCell.new
        data_cell1_para = Uniword::Wordprocessingml::Paragraph.new
        data_cell1_run = Uniword::Wordprocessingml::Run.new(text: "Data 1")
        data_cell1_para.runs << data_cell1_run
        data_cell1.paragraphs << data_cell1_para
        data_row.cells << data_cell1

        data_cell2 = Uniword::Wordprocessingml::TableCell.new
        data_cell2_para = Uniword::Wordprocessingml::Paragraph.new
        data_cell2_run = Uniword::Wordprocessingml::Run.new(text: "Data 2")
        data_cell2_para.runs << data_cell2_run
        data_cell2.paragraphs << data_cell2_para
        data_row.cells << data_cell2

        table.rows << data_row

        doc.body.tables << table

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include("tblHeader")
        expect(xml).to include("Header 1")
        expect(xml).to include("Data 1")
      end

      it "generates DOCX with table properties" do
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        table = Uniword::Wordprocessingml::Table.new
        table.properties = Uniword::Wordprocessingml::TableProperties.new(
          width: "5000",
          alignment: "center",
        )

        row = Uniword::Wordprocessingml::TableRow.new
        cell = Uniword::Wordprocessingml::TableCell.new
        cell_para = Uniword::Wordprocessingml::Paragraph.new
        cell_run = Uniword::Wordprocessingml::Run.new(text: "Content")
        cell_para.runs << cell_run
        cell.paragraphs << cell_para
        row.cells << cell
        table.rows << row

        doc.body.tables << table

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include('<w:tblW w:w="5000" w:type="dxa"/>')
        expect(xml).to include('<w:jc w:val="center"/>')
      end

      it "generates DOCX with cell background color" do
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        table = Uniword::Wordprocessingml::Table.new
        row = Uniword::Wordprocessingml::TableRow.new

        cell = Uniword::Wordprocessingml::TableCell.new
        cell.properties = Uniword::Wordprocessingml::TableCellProperties.new(shading: Uniword::Properties::Shading.new(fill: "FFFF00"))
        cell_para = Uniword::Wordprocessingml::Paragraph.new
        cell_run = Uniword::Wordprocessingml::Run.new(text: "Highlighted")
        cell_para.runs << cell_run
        cell.paragraphs << cell_para
        row.cells << cell

        table.rows << row
        doc.body.tables << table

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include("<w:shd")
        expect(xml).to include("FFFF00")
      end
    end

    describe "mixed content generation" do
      it "generates DOCX with paragraphs and tables" do
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        # Add a paragraph
        para1 = Uniword::Wordprocessingml::Paragraph.new
        para1_run = Uniword::Wordprocessingml::Run.new(text: "Introduction text")
        para1.runs << para1_run
        doc.body.paragraphs << para1

        # Add a table
        table = Uniword::Wordprocessingml::Table.new
        row = Uniword::Wordprocessingml::TableRow.new
        cell = Uniword::Wordprocessingml::TableCell.new
        cell_para = Uniword::Wordprocessingml::Paragraph.new
        cell_run = Uniword::Wordprocessingml::Run.new(text: "Table content")
        cell_para.runs << cell_run
        cell.paragraphs << cell_para
        row.cells << cell
        table.rows << row
        doc.body.tables << table

        # Add another paragraph
        para2 = Uniword::Wordprocessingml::Paragraph.new
        para2_run = Uniword::Wordprocessingml::Run.new(text: "Conclusion text")
        para2.runs << para2_run
        doc.body.paragraphs << para2

        serializer = Uniword::Serialization::OoxmlSerializer.new
        xml = serializer.serialize(doc)

        expect(xml).to include("Introduction text")
        expect(xml).to include("<w:tbl>")
        expect(xml).to include("Table content")
        expect(xml).to include("Conclusion text")
      end
    end
  end
end
