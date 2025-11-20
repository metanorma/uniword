# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'docx gem API Compatibility' do
  describe 'Document operations' do
    it "supports Document.open(path)" do
      doc = Uniword::Document.open('spec/fixtures/basic.docx')
      expect(doc).to be_a(Uniword::Document)
    end

    it "supports doc.text to get plain text" do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text("Hello World")
      doc.add_element(para)

      expect(doc.text).to eq("Hello World")
    end

    it "supports doc.to_html for HTML export" do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text("Hello World")
      doc.add_element(para)

      html = doc.to_html
      expect(html).to be_a(String)
      expect(html).to include("<p>")
      expect(html).to include("Hello World")
    end

    it "supports doc.stream for StringIO output" do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text("Hello World")
      doc.add_element(para)

      stream = doc.stream
      expect(stream).to be_a(StringIO)
      expect(stream.size).to be > 0
    end

    it "supports doc.paragraphs" do
      doc = Uniword::Document.new
      para1 = Uniword::Paragraph.new.add_text("Para 1")
      para2 = Uniword::Paragraph.new.add_text("Para 2")
      doc.add_element(para1)
      doc.add_element(para2)

      expect(doc.paragraphs.count).to eq(2)
      expect(doc.paragraphs.first).to be_a(Uniword::Paragraph)
    end

    it "supports doc.tables" do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      doc.add_element(table)

      expect(doc.tables.count).to eq(1)
      expect(doc.tables.first).to be_a(Uniword::Table)
    end
  end

  describe 'Paragraph operations' do
    it "supports paragraph.text to get content" do
      para = Uniword::Paragraph.new
      para.add_text("Hello")
      para.add_text(" World")

      expect(para.text).to eq("Hello World")
    end

    it "supports paragraph.text= to set content" do
      para = Uniword::Paragraph.new
      para.add_text("Old text")

      para.text = "New text"
      expect(para.text).to eq("New text")
      expect(para.runs.count).to eq(1)
    end

    it "supports paragraph.to_html" do
      para = Uniword::Paragraph.new
      para.add_text("Hello World")

      html = para.to_html
      expect(html).to include("<p>")
      expect(html).to include("Hello World")
      expect(html).to include("</p>")
    end

    it "supports paragraph.remove!" do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text("Remove me")
      doc.add_element(para)

      expect(doc.paragraphs.count).to eq(1)
      para.remove!
      expect(doc.paragraphs.count).to eq(0)
    end

    it "supports paragraph.each_text_run" do
      para = Uniword::Paragraph.new
      para.add_text("Hello")
      para.add_text(" World")

      texts = []
      para.each_text_run { |run| texts << run.text }
      expect(texts).to eq(["Hello", " World"])
    end

    it "supports paragraph.style" do
      para = Uniword::Paragraph.new
      para.set_style("Heading1")

      expect(para.style).to eq("Heading1")
    end

    it "supports paragraph.alignment" do
      para = Uniword::Paragraph.new
      para.align("center")

      expect(para.alignment).to eq("center")
    end
  end

  describe 'Run operations' do
    it "supports run.text to get content" do
      run = Uniword::Run.new(text: "Hello World")
      expect(run.text).to eq("Hello World")
    end

    it "supports run.text= to set content" do
      run = Uniword::Run.new(text: "Old")
      run.text = "New"
      expect(run.text).to eq("New")
    end

    it "supports run.substitute for simple replacement" do
      run = Uniword::Run.new(text: "Hello _name_")
      run.substitute('_name_', 'World')
      expect(run.text).to eq("Hello World")
    end

    it "supports run.substitute with regex" do
      run = Uniword::Run.new(text: "Hello WORLD")
      run.substitute(/[A-Z]+/, 'World')
      expect(run.text).to eq("Hello World")
    end

    it "supports run.substitute_with_block for captures" do
      run = Uniword::Run.new(text: "total: 5")
      run.substitute_with_block(/total: (\d+)/) do |match|
        "total: #{match[1].to_i * 10}"
      end
      expect(run.text).to eq("total: 50")
    end

    it "supports run.substitute_with_block for multiple captures" do
      run = Uniword::Run.new(text: "add 3 and 4")
      run.substitute_with_block(/add (\d+) and (\d+)/) do |match|
        result = match[1].to_i + match[2].to_i
        "result: #{result}"
      end
      expect(run.text).to eq("result: 7")
    end

    it "supports run.bold?" do
      run = Uniword::Run.new(text: "Bold", properties: Uniword::Properties::RunProperties.new(bold: true))
      expect(run.bold?).to be true

      plain_run = Uniword::Run.new(text: "Plain")
      expect(plain_run.bold?).to be false
    end

    it "supports run.italic?" do
      run = Uniword::Run.new(text: "Italic", properties: Uniword::Properties::RunProperties.new(italic: true))
      expect(run.italic?).to be true
    end

    it "supports run.underline?" do
      run = Uniword::Run.new(text: "Underlined", properties: Uniword::Properties::RunProperties.new(underline: "single"))
      expect(run.underline?).to be true
    end

    it "supports run.strike? / run.striked?" do
      run = Uniword::Run.new(text: "Strike", properties: Uniword::Properties::RunProperties.new(strike: true))
      expect(run.strike?).to be true
      expect(run.striked?).to be true
    end

    it "supports run.to_html" do
      run = Uniword::Run.new(text: "Hello", properties: Uniword::Properties::RunProperties.new(bold: true))
      html = run.to_html
      expect(html).to include("<strong>")
      expect(html).to include("Hello")
    end

    it "supports run.font_size" do
      run = Uniword::Run.new(text: "Text", properties: Uniword::Properties::RunProperties.new(size: 24))
      expect(run.font_size).to eq(12)  # size is in half-points
    end
  end

  describe 'Table operations' do
    it "supports table.rows" do
      table = Uniword::Table.new
      row1 = Uniword::TableRow.new
      row2 = Uniword::TableRow.new
      table.add_row(row1)
      table.add_row(row2)

      expect(table.rows.count).to eq(2)
    end

    it "supports table.row_count" do
      table = Uniword::Table.new
      table.add_row(Uniword::TableRow.new)
      table.add_row(Uniword::TableRow.new)

      expect(table.row_count).to eq(2)
    end

    it "supports table.column_count" do
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      row.add_text_cell("Cell 1")
      row.add_text_cell("Cell 2")
      row.add_text_cell("Cell 3")
      table.add_row(row)

      expect(table.column_count).to eq(3)
    end

    it "supports table.columns for column-based iteration" do
      table = Uniword::Table.new
      row1 = Uniword::TableRow.new
      row1.add_text_cell("A1")
      row1.add_text_cell("B1")
      table.add_row(row1)

      row2 = Uniword::TableRow.new
      row2.add_text_cell("A2")
      row2.add_text_cell("B2")
      table.add_row(row2)

      columns = table.columns
      expect(columns.count).to eq(2)
      expect(columns[0]).to be_a(Uniword::TableColumn)

      # Check column content
      col0_texts = columns[0].cells.map { |cell| cell.paragraphs.first.text }
      expect(col0_texts).to eq(["A1", "A2"])
    end

    it "supports row.copy to duplicate a row" do
      row = Uniword::TableRow.new(header: true)
      row.add_text_cell("Cell 1")
      row.add_text_cell("Cell 2")

      new_row = row.copy
      expect(new_row).to be_a(Uniword::TableRow)
      expect(new_row).not_to eq(row)
      expect(new_row.cells.count).to eq(row.cells.count)
      expect(new_row.header?).to be true

      # Verify deep copy
      expect(new_row.cells.first.paragraphs.first.text).to eq("Cell 1")
    end

    it "supports row.insert_before to insert row before another" do
      table = Uniword::Table.new
      row1 = Uniword::TableRow.new
      row1.add_text_cell("Row 1")
      row2 = Uniword::TableRow.new
      row2.add_text_cell("Row 2")
      table.add_row(row1)
      table.add_row(row2)

      new_row = Uniword::TableRow.new
      new_row.add_text_cell("New Row")
      new_row.insert_before(row2)

      expect(table.rows.count).to eq(3)
      expect(table.rows[1]).to eq(new_row)
      expect(table.rows[2]).to eq(row2)
    end

    it "supports row.cells" do
      row = Uniword::TableRow.new
      row.add_text_cell("Cell 1")
      row.add_text_cell("Cell 2")

      expect(row.cells.count).to eq(2)
      expect(row.cells.first).to be_a(Uniword::TableCell)
    end

    it "supports cell.paragraphs" do
      cell = Uniword::TableCell.new
      cell.add_text("Text 1")
      cell.add_text("Text 2")

      expect(cell.paragraphs.count).to eq(2)
    end
  end

  describe 'Integration scenarios' do
    it "supports complex text substitution workflow" do
      doc = Uniword::Document.new

      para1 = Uniword::Paragraph.new
      para1.add_text("Dear _name_,")
      doc.add_element(para1)

      para2 = Uniword::Paragraph.new
      para2.add_text("Your total is $__amount__.")
      doc.add_element(para2)

      # Substitute placeholders
      doc.paragraphs.each do |p|
        p.each_text_run do |run|
          run.substitute('_name_', 'John Doe')
          run.substitute('__amount__', '150.00')
        end
      end

      expect(doc.paragraphs[0].text).to eq("Dear John Doe,")
      expect(doc.paragraphs[1].text).to eq("Your total is $150.00.")
    end

    it "supports table manipulation workflow" do
      table = Uniword::Table.new

      # Add header row
      header = Uniword::TableRow.new(header: true)
      header.add_text_cell("Name")
      header.add_text_cell("Age")
      table.add_row(header)

      # Add data row
      data_row = Uniword::TableRow.new
      data_row.add_text_cell("_name_")
      data_row.add_text_cell("_age_")
      table.add_row(data_row)

      # Copy row and insert
      last_row = table.rows.last
      new_row = last_row.copy
      new_row.insert_before(last_row)

      expect(table.rows.count).to eq(3)

      # Substitute in all rows
      table.rows.each do |row|
        row.cells.each do |cell|
          cell.paragraphs.each do |para|
            para.each_text_run do |run|
              run.substitute('_name_', 'Alice')
              run.substitute('_age_', '30')
            end
          end
        end
      end

      expect(table.rows[1].cells[0].paragraphs.first.text).to eq("Alice")
      expect(table.rows[2].cells[1].paragraphs.first.text).to eq("30")
    end
  end
end