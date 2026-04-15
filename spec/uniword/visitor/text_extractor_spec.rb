# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Visitor::TextExtractor do
  let(:extractor) { described_class.new }

  describe "#initialize" do
    it "accepts a separator parameter" do
      custom_extractor = described_class.new(separator: " | ")
      expect(custom_extractor).to be_a(described_class)
    end

    it "defaults to newline separator" do
      extractor = described_class.new
      expect(extractor).to be_a(described_class)
    end
  end

  describe "#text" do
    it "returns empty string initially" do
      expect(extractor.text).to eq("")
    end

    it "returns extracted text joined by separator" do
      run1 = Uniword::Wordprocessingml::Run.new(text: "Hello")
      run2 = Uniword::Wordprocessingml::Run.new(text: "World")

      run1.accept(extractor)
      run2.accept(extractor)

      expect(extractor.text).to eq("Hello\nWorld")
    end

    it "uses custom separator when provided" do
      custom_extractor = described_class.new(separator: " | ")
      run1 = Uniword::Wordprocessingml::Run.new(text: "Hello")
      run2 = Uniword::Wordprocessingml::Run.new(text: "World")

      run1.accept(custom_extractor)
      run2.accept(custom_extractor)

      expect(custom_extractor.text).to eq("Hello | World")
    end
  end

  describe "#visit_document" do
    it "extracts text from all document elements" do
      document = Uniword::Wordprocessingml::DocumentRoot.new
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "First paragraph")
      para1.runs << run1
      document.body.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: "Second paragraph")
      para2.runs << run2
      document.body.paragraphs << para2

      extractor.visit_document(document)

      expect(extractor.text).to eq("First paragraph\nSecond paragraph")
    end

    it "handles empty documents" do
      document = Uniword::Wordprocessingml::DocumentRoot.new
      extractor.visit_document(document)
      expect(extractor.text).to eq("")
    end
  end

  describe "#visit_paragraph" do
    it "extracts text from all runs in paragraph" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "Hello ")
      run2 = Uniword::Wordprocessingml::Run.new(text: "World")
      paragraph.runs << run1
      paragraph.runs << run2

      extractor.visit_paragraph(paragraph)

      expect(extractor.text).to eq("Hello World")
    end

    it "handles empty paragraphs" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      extractor.visit_paragraph(paragraph)
      expect(extractor.text).to eq("")
    end

    it "handles paragraphs with empty runs" do
      paragraph = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "")
      paragraph.runs << run

      extractor.visit_paragraph(paragraph)

      expect(extractor.text).to eq("")
    end
  end

  describe "#visit_table" do
    it "extracts text from all table rows" do
      table = Uniword::Wordprocessingml::Table.new
      table.rows << Uniword::Wordprocessingml::TableRow.new.tap do |row|
        row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "Cell 1")
          para.runs << run
          cell.paragraphs << para
        end
        row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "Cell 2")
          para.runs << run
          cell.paragraphs << para
        end
      end
      table.rows << Uniword::Wordprocessingml::TableRow.new.tap do |row|
        row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "Cell 3")
          para.runs << run
          cell.paragraphs << para
        end
        row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "Cell 4")
          para.runs << run
          cell.paragraphs << para
        end
      end

      extractor.visit_table(table)

      expect(extractor.text).to eq("Cell 1 | Cell 2\nCell 3 | Cell 4")
    end

    it "handles empty tables" do
      table = Uniword::Wordprocessingml::Table.new
      extractor.visit_table(table)
      expect(extractor.text).to eq("")
    end
  end

  describe "#visit_table_row" do
    it "extracts text from all cells separated by pipes" do
      row = Uniword::Wordprocessingml::TableRow.new
      row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Cell 1")
        para.runs << run
        cell.paragraphs << para
      end
      row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Cell 2")
        para.runs << run
        cell.paragraphs << para
      end
      row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Cell 3")
        para.runs << run
        cell.paragraphs << para
      end

      extractor.visit_table_row(row)

      expect(extractor.text).to eq("Cell 1 | Cell 2 | Cell 3")
    end

    it "handles empty rows" do
      row = Uniword::Wordprocessingml::TableRow.new
      extractor.visit_table_row(row)
      expect(extractor.text).to eq("")
    end
  end

  describe "#visit_table_cell" do
    it "extracts text from all paragraphs in cell" do
      cell = Uniword::Wordprocessingml::TableCell.new
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "First line")
      para1.runs << run1
      cell.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: "Second line")
      para2.runs << run2
      cell.paragraphs << para2

      extractor.visit_table_cell(cell)

      expect(extractor.text).to eq("First lineSecond line")
    end

    it "handles empty cells" do
      cell = Uniword::Wordprocessingml::TableCell.new
      extractor.visit_table_cell(cell)
      expect(extractor.text).to eq("")
    end
  end

  describe "#visit_run" do
    it "extracts text from run" do
      run = Uniword::Wordprocessingml::Run.new(text: "Hello World")
      extractor.visit_run(run)
      expect(extractor.text).to eq("Hello World")
    end

    it "handles runs with nil text" do
      run = Uniword::Wordprocessingml::Run.new
      extractor.visit_run(run)
      expect(extractor.text).to eq("")
    end

    it "handles runs with empty text" do
      run = Uniword::Wordprocessingml::Run.new(text: "")
      extractor.visit_run(run)
      expect(extractor.text).to eq("")
    end
  end

  describe "#visit_image" do
    it "does not extract any text from images" do
      image = Uniword::Image.new(relationship_id: "rId1")
      extractor.visit_image(image)
      expect(extractor.text).to eq("")
    end
  end

  describe "complex document extraction" do
    it "extracts text from mixed content document" do
      document = Uniword::Wordprocessingml::DocumentRoot.new

      # Add paragraphs
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "This is a paragraph.")
      para1.runs << run1
      document.body.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: "Final paragraph")
      para2.runs << run2
      document.body.paragraphs << para2

      # Add table
      table = Uniword::Wordprocessingml::Table.new
      table.rows << Uniword::Wordprocessingml::TableRow.new.tap do |row|
        row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "Header 1")
          para.runs << run
          cell.paragraphs << para
        end
        row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "Header 2")
          para.runs << run
          cell.paragraphs << para
        end
      end
      table.rows << Uniword::Wordprocessingml::TableRow.new.tap do |row|
        row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "Data 1")
          para.runs << run
          cell.paragraphs << para
        end
        row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "Data 2")
          para.runs << run
          cell.paragraphs << para
        end
      end
      document.body.tables << table

      extractor.visit_document(document)

      # body.elements returns paragraphs first, then tables
      expected_text = "This is a paragraph.\n" \
                      "Final paragraph\n" \
                      "Header 1 | Header 2\n" \
                      "Data 1 | Data 2"

      expect(extractor.text).to eq(expected_text)
    end

    it "handles nested table cells with multiple paragraphs" do
      table = Uniword::Wordprocessingml::Table.new
      row = Uniword::Wordprocessingml::TableRow.new

      cell = Uniword::Wordprocessingml::TableCell.new
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "Line 1")
      para1.runs << run1
      cell.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: "Line 2")
      para2.runs << run2
      cell.paragraphs << para2
      row.cells << cell

      cell2 = Uniword::Wordprocessingml::TableCell.new
      para3 = Uniword::Wordprocessingml::Paragraph.new
      run3 = Uniword::Wordprocessingml::Run.new(text: "Cell 2")
      para3.runs << run3
      cell2.paragraphs << para3
      row.cells << cell2

      table.rows << row

      extractor.visit_table(table)

      expect(extractor.text).to eq("Line 1Line 2 | Cell 2")
    end
  end

  describe "inheritance from BaseVisitor" do
    it "inherits from BaseVisitor" do
      expect(described_class).to be < Uniword::Visitor::BaseVisitor
    end

    it "overrides all visit methods" do
      expect(described_class.instance_method(:visit_document)).not_to eq(
        Uniword::Visitor::BaseVisitor.instance_method(:visit_document)
      )
      expect(described_class.instance_method(:visit_paragraph)).not_to eq(
        Uniword::Visitor::BaseVisitor.instance_method(:visit_paragraph)
      )
      expect(described_class.instance_method(:visit_table)).not_to eq(
        Uniword::Visitor::BaseVisitor.instance_method(:visit_table)
      )
      expect(described_class.instance_method(:visit_run)).not_to eq(
        Uniword::Visitor::BaseVisitor.instance_method(:visit_run)
      )
    end
  end
end
