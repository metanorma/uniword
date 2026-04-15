# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::DocumentRoot do
  describe ".new" do
    it "creates a new document" do
      document = described_class.new
      expect(document).to be_a(Uniword::Wordprocessingml::DocumentRoot)
    end

    it "initializes with a default body" do
      document = described_class.new
      expect(document.body).to be_a(Uniword::Wordprocessingml::Body)
      expect(document.body.paragraphs).to be_empty
    end

    it "has empty paragraphs when body is nil" do
      document = described_class.new
      expect(document.paragraphs).to eq([])
    end
  end

  describe "#add_paragraph" do
    let(:document) { described_class.new }

    it "adds paragraph to existing body" do
      expect(document.body).to be_a(Uniword::Wordprocessingml::Body)
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Hello")
      para.runs << run
      document.body.paragraphs << para
      expect(document.body.paragraphs.count).to eq(1)
    end

    it "adds a paragraph with text" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Hello World")
      para.runs << run
      document.body.paragraphs << para
      expect(para).to be_a(Uniword::Wordprocessingml::Paragraph)
      expect(para.text).to eq("Hello World")
    end

    it "adds paragraph to body.paragraphs" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Test")
      para.runs << run
      document.body.paragraphs << para
      expect(document.body.paragraphs).to include(para)
    end

    it "applies bold formatting" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Bold text")
      run.properties = Uniword::Wordprocessingml::RunProperties.new
      run.properties.bold = Uniword::Properties::Bold.new(value: true)
      para.runs << run
      document.body.paragraphs << para
      expect(para.runs.first.properties.bold).to be_truthy
    end

    it "applies italic formatting" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Italic text")
      run.properties = Uniword::Wordprocessingml::RunProperties.new
      run.properties.italic = Uniword::Properties::Italic.new(value: true)
      para.runs << run
      document.body.paragraphs << para
      expect(para.runs.first.properties.italic).to be_truthy
    end

    it "applies style" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Heading")
      para.runs << run
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new
      para.properties.style = "Heading1"
      document.body.paragraphs << para
      expect(para.properties.style).to eq("Heading1")
    end

    it "applies heading option" do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Title")
      para.runs << run
      para.properties = Uniword::Wordprocessingml::ParagraphProperties.new
      para.properties.style = "Heading1"
      document.body.paragraphs << para
      expect(para.properties.style).to eq("Heading1")
    end
  end

  describe "#add_table" do
    let(:document) { described_class.new }

    def create_table(num_rows, num_cols)
      table = Uniword::Wordprocessingml::Table.new
      num_rows.times do
        row = Uniword::Wordprocessingml::TableRow.new
        num_cols.times do
          row.cells << Uniword::Wordprocessingml::TableCell.new
        end
        table.rows << row
      end
      table
    end

    it "adds table to existing body" do
      expect(document.body).to be_a(Uniword::Wordprocessingml::Body)
      table = create_table(2, 2)
      document.body.tables << table
      expect(document.body.tables.count).to eq(1)
    end

    it "creates table with dimensions" do
      table = create_table(2, 3)
      document.body.tables << table
      expect(table).to be_a(Uniword::Wordprocessingml::Table)
      expect(table.rows.count).to eq(2)
      expect(table.rows.first.cells.count).to eq(3)
    end

    it "adds table to body.tables" do
      table = create_table(1, 1)
      document.body.tables << table
      expect(document.body.tables).to include(table)
    end
  end

  describe "#text" do
    let(:document) { described_class.new }

    it "returns empty string for empty document" do
      expect(document.text).to eq("")
    end

    it "returns combined paragraph text" do
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "First")
      para1.runs << run1
      document.body.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: "Second")
      para2.runs << run2
      document.body.paragraphs << para2
      expect(document.text).to eq("First\nSecond")
    end
  end

  describe "#paragraphs" do
    let(:document) { described_class.new }

    it "returns empty array when no body" do
      expect(document.paragraphs).to eq([])
    end

    it "returns paragraphs from body" do
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "One")
      para1.runs << run1
      document.body.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: "Two")
      para2.runs << run2
      document.body.paragraphs << para2
      expect(document.body.paragraphs.count).to eq(2)
    end
  end

  describe "#tables" do
    let(:document) { described_class.new }

    it "returns empty array when no body" do
      expect(document.tables).to eq([])
    end

    it "returns tables from body" do
      table1 = Uniword::Wordprocessingml::Table.new
      row1 = Uniword::Wordprocessingml::TableRow.new
      row1.cells << Uniword::Wordprocessingml::TableCell.new
      table1.rows << row1
      document.body.tables << table1
      table2 = Uniword::Wordprocessingml::Table.new
      2.times do
        row = Uniword::Wordprocessingml::TableRow.new
        2.times { row.cells << Uniword::Wordprocessingml::TableCell.new }
        table2.rows << row
      end
      document.body.tables << table2
      expect(document.body.tables.count).to eq(2)
    end
  end
end
