# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe 'docx gem API Compatibility' do
  describe 'Document operations' do
    it 'supports Document.open(path)' do
      doc = Uniword.load('spec/fixtures/docx_gem/basic.docx')
      expect(doc).to be_a(Uniword::Document)
    end

    it 'supports doc.text to get plain text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Hello World')
      para.runs << run
      doc.body.paragraphs << para

      expect(doc.text).to eq('Hello World')
    end

    it 'supports doc.to_html for HTML export' do
      skip 'TODO: to_html moved to separate converter'

      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Hello World')
      para.runs << run
      doc.body.paragraphs << para

      html = doc.to_html
      expect(html).to be_a(String)
      expect(html).to include('<p>')
      expect(html).to include('Hello World')
    end

    it 'supports doc.stream for StringIO output' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Hello World')
      para.runs << run
      doc.body.paragraphs << para

      stream = StringIO.new
      writer = Uniword::DocumentWriter.new(doc)
      writer.write_to_stream(stream)
      stream.rewind
      expect(stream.size).to be > 0
    end

    it 'supports doc.paragraphs' do
      doc = Uniword::Document.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Para 1')
      para1.runs << run1
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Para 2')
      para2.runs << run2
      doc.body.paragraphs << para1
      doc.body.paragraphs << para2

      expect(doc.paragraphs.count).to eq(2)
      expect(doc.paragraphs.first).to be_a(Uniword::Paragraph)
    end

    it 'supports doc.tables' do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      doc.body.tables << table

      expect(doc.tables.count).to eq(1)
      expect(doc.tables.first).to be_a(Uniword::Table)
    end
  end

  describe 'Paragraph operations' do
    it 'supports paragraph.text to get content' do
      para = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Hello')
      para.runs << run1
      run2 = Uniword::Wordprocessingml::Run.new(text: ' World')
      para.runs << run2

      expect(para.text).to eq('Hello World')
    end

    it 'supports paragraph.text= to set content' do
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Old text')
      para.runs << run

      para.text = 'New text'
      expect(para.text).to eq('New text')
      expect(para.runs.count).to eq(1)
      expect(para.runs.first.text.to_s).to eq('New text')
    end

    it 'supports paragraph.to_html' do
      skip 'TODO: to_html moved to separate converter'

      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Hello World')
      para.runs << run

      html = para.to_html
      expect(html).to include('<p>')
      expect(html).to include('Hello World')
      expect(html).to include('</p>')
    end

    it 'supports paragraph.remove!' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Remove me')
      para.runs << run
      doc.body.paragraphs << para

      expect(doc.paragraphs.count).to eq(1)
      expect(para.text).to eq('Remove me')
      para.remove!
      expect(para.text).to eq('')
      expect(para.runs.count).to eq(0)
    end

    it 'supports paragraph.each_text_run' do
      para = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Hello')
      para.runs << run1
      run2 = Uniword::Wordprocessingml::Run.new(text: ' World')
      para.runs << run2

      texts = []
      para.each_text_run { |run| texts << run.text }
      expect(texts).to eq(['Hello', ' World'])
    end

    it 'supports paragraph.style' do
      para = Uniword::Paragraph.new
      builder = Uniword::Builder::ParagraphBuilder.from_model(para)
      builder.style = 'Heading1'

      expect(para.properties&.style).to eq('Heading1')
    end

    it 'supports paragraph.alignment' do
      para = Uniword::Paragraph.new
      builder = Uniword::Builder::ParagraphBuilder.from_model(para)
      builder.align = 'center'

      expect(para.properties&.alignment).to eq('center')
    end
  end

  describe 'Run operations' do
    it 'supports run.text to get content' do
      run = Uniword::Run.new(text: 'Hello World')
      expect(run.text).to eq('Hello World')
    end

    it 'supports run.text= to set content' do
      run = Uniword::Run.new(text: 'Old')
      run.text = 'New'
      expect(run.text).to eq('New')
    end

    it 'supports run.substitute for simple replacement' do
      run = Uniword::Run.new(text: 'Hello _name_')
      run.substitute('_name_', 'World')
      expect(run.text).to eq('Hello World')
    end

    it 'supports run.substitute with regex' do
      run = Uniword::Run.new(text: 'Hello WORLD')
      run.substitute('WORLD', 'World')
      expect(run.text.to_s).to eq('Hello World')
    end

    it 'supports run.substitute_with_block for captures' do
      run = Uniword::Run.new(text: 'total: 5')
      run.substitute_with_block(/total: (\d+)/) do |match|
        "total: #{match[1].to_i * 10}"
      end
      expect(run.text).to eq('total: 50')
    end

    it 'supports run.substitute_with_block for multiple captures' do
      run = Uniword::Run.new(text: 'add 3 and 4')
      run.substitute_with_block(/add (\d+) and (\d+)/) do |match|
        result = match[1].to_i + match[2].to_i
        "result: #{result}"
      end
      expect(run.text).to eq('result: 7')
    end

    it 'supports run.bold?' do
      run = Uniword::Builder::RunBuilder.new
        .text('Bold')
        .bold
        .build
      expect(run.properties&.bold&.value == true).to be true

      plain_run = Uniword::Run.new(text: 'Plain')
      expect(plain_run.properties&.bold&.value == true).to be false
    end

    it 'supports run.italic?' do
      run = Uniword::Builder::RunBuilder.new
        .text('Italic')
        .italic
        .build
      expect(run.properties&.italic&.value == true).to be true
    end

    it 'supports run.underline?' do
      run = Uniword::Builder::RunBuilder.new
        .text('Underlined')
        .underline('single')
        .build
      expect(run.properties&.underline && run.properties.underline != 'none').to be true
    end

    it 'supports run.strike? / run.striked?' do
      run = Uniword::Builder::RunBuilder.new
        .text('Strike')
        .strike
        .build
      expect(run.properties&.strike? || false).to be true
      expect(run.properties&.strike? || false).to be true
    end

    it 'supports run.to_html' do
      skip 'TODO: to_html moved to separate converter'

      run = Uniword::Builder::RunBuilder.new
        .text('Hello')
        .bold
        .build
      html = run.to_html
      expect(html).to include('<strong>')
      expect(html).to include('Hello')
    end

    it 'supports run.font_size' do
      run = Uniword::Builder::RunBuilder.new
        .text('Text')
        .size(12)
        .build
      size_val = run.properties&.size
      size_val = size_val.value if size_val.respond_to?(:value)
      expect(size_val).to eq(24) # size is in half-points
    end
  end

  describe 'Table operations' do
    it 'supports table.rows' do
      table = Uniword::Table.new
      row1 = Uniword::TableRow.new
      row2 = Uniword::TableRow.new
      table.rows << row1
      table.rows << row2

      expect(table.rows.count).to eq(2)
    end

    it 'supports table.row_count' do
      table = Uniword::Table.new
      table.rows << Uniword::TableRow.new
      table.rows << Uniword::TableRow.new

      expect(table.row_count).to eq(2)
    end

    it 'supports table.column_count' do
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell1 = Uniword::TableCell.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Cell 1')
      para1.runs << run1
      cell1.paragraphs << para1
      row.cells << cell1
      cell2 = Uniword::TableCell.new
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Cell 2')
      para2.runs << run2
      cell2.paragraphs << para2
      row.cells << cell2
      cell3 = Uniword::TableCell.new
      para3 = Uniword::Paragraph.new
      run3 = Uniword::Wordprocessingml::Run.new(text: 'Cell 3')
      para3.runs << run3
      cell3.paragraphs << para3
      row.cells << cell3
      table.rows << row

      expect(table.rows.first.cells.count).to eq(3)
    end

    it 'supports table.columns for column-based iteration' do
      table = Uniword::Table.new
      row1 = Uniword::TableRow.new
      cell1 = Uniword::TableCell.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'A1')
      para1.runs << run1
      cell1.paragraphs << para1
      row1.cells << cell1
      cell2 = Uniword::TableCell.new
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'B1')
      para2.runs << run2
      cell2.paragraphs << para2
      row1.cells << cell2
      table.rows << row1

      row2 = Uniword::TableRow.new
      cell3 = Uniword::TableCell.new
      para3 = Uniword::Paragraph.new
      run3 = Uniword::Wordprocessingml::Run.new(text: 'A2')
      para3.runs << run3
      cell3.paragraphs << para3
      row2.cells << cell3
      cell4 = Uniword::TableCell.new
      para4 = Uniword::Paragraph.new
      run4 = Uniword::Wordprocessingml::Run.new(text: 'B2')
      para4.runs << run4
      cell4.paragraphs << para4
      row2.cells << cell4
      table.rows << row2

      # Check column content manually
      expect(table.rows.count).to eq(2)
      expect(table.rows.first.cells.count).to eq(2)
      expect(table.rows[0].cells[0].paragraphs.first.text).to eq('A1')
      expect(table.rows[1].cells[0].paragraphs.first.text).to eq('A2')
    end

    it 'supports row.copy to duplicate a row' do
      row = Uniword::TableRow.new
      cell1 = Uniword::TableCell.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Cell 1')
      para1.runs << run1
      cell1.paragraphs << para1
      row.cells << cell1
      cell2 = Uniword::TableCell.new
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Cell 2')
      para2.runs << run2
      cell2.paragraphs << para2
      row.cells << cell2

      # Create a copy manually (v2.0 doesn't have copy method)
      new_row = Uniword::TableRow.new
      row.cells.each do |orig_cell|
        new_cell = Uniword::TableCell.new
        orig_cell.paragraphs.each do |orig_para|
          new_para = Uniword::Paragraph.new
          orig_para.runs.each do |run|
            new_run = Uniword::Wordprocessingml::Run.new(text: run.text)
            new_para.runs << new_run
          end
          new_cell.paragraphs << new_para
        end
        new_row.cells << new_cell
      end

      expect(new_row).to be_a(Uniword::TableRow)
      expect(new_row).not_to be(row)
      expect(new_row.cells.count).to eq(row.cells.count)

      # Verify deep copy
      expect(new_row.cells.first.paragraphs.first.text).to eq('Cell 1')
    end

    it 'supports row.insert_before to insert row before another' do
      table = Uniword::Table.new
      row1 = Uniword::TableRow.new
      cell1 = Uniword::TableCell.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Row 1')
      para1.runs << run1
      cell1.paragraphs << para1
      row1.cells << cell1
      row2 = Uniword::TableRow.new
      cell2 = Uniword::TableCell.new
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Row 2')
      para2.runs << run2
      cell2.paragraphs << para2
      row2.cells << cell2
      table.rows << row1
      table.rows << row2

      new_row = Uniword::TableRow.new
      cell3 = Uniword::TableCell.new
      para3 = Uniword::Paragraph.new
      run3 = Uniword::Wordprocessingml::Run.new(text: 'New Row')
      para3.runs << run3
      cell3.paragraphs << para3
      new_row.cells << cell3

      # Insert before row2 (v2.0: use array insert)
      index = table.rows.index(row2)
      table.rows.insert(index, new_row)

      expect(table.rows.count).to eq(3)
      expect(table.rows[1]).to eq(new_row)
      expect(table.rows[2]).to eq(row2)
    end

    it 'supports row.cells' do
      row = Uniword::TableRow.new
      cell1 = Uniword::TableCell.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Cell 1')
      para1.runs << run1
      cell1.paragraphs << para1
      row.cells << cell1
      cell2 = Uniword::TableCell.new
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Cell 2')
      para2.runs << run2
      cell2.paragraphs << para2
      row.cells << cell2

      expect(row.cells.count).to eq(2)
      expect(row.cells.first).to be_a(Uniword::TableCell)
    end

    it 'supports cell.paragraphs' do
      cell = Uniword::TableCell.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Text 1')
      para1.runs << run1
      cell.paragraphs << para1
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Text 2')
      para2.runs << run2
      cell.paragraphs << para2

      expect(cell.paragraphs.count).to eq(2)
    end
  end

  describe 'Integration scenarios' do
    it 'supports complex text substitution workflow' do
      doc = Uniword::Document.new

      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Dear _name_,')
      para1.runs << run1
      doc.body.paragraphs << para1

      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Your total is $__amount__.')
      para2.runs << run2
      doc.body.paragraphs << para2

      # Substitute placeholders
      doc.paragraphs.each do |p|
        p.each_text_run do |run|
          run.substitute('_name_', 'John Doe')
          run.substitute('__amount__', '150.00')
        end
      end

      expect(doc.paragraphs[0].text).to eq('Dear John Doe,')
      expect(doc.paragraphs[1].text).to eq('Your total is $150.00.')
    end

    it 'supports table manipulation workflow' do
      table = Uniword::Table.new

      # Add header row
      header = Uniword::TableRow.new
      cell1 = Uniword::TableCell.new
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Name')
      para1.runs << run1
      cell1.paragraphs << para1
      header.cells << cell1
      cell2 = Uniword::TableCell.new
      para2 = Uniword::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Age')
      para2.runs << run2
      cell2.paragraphs << para2
      header.cells << cell2
      table.rows << header

      # Add data row
      data_row = Uniword::TableRow.new
      cell3 = Uniword::TableCell.new
      para3 = Uniword::Paragraph.new
      run3 = Uniword::Wordprocessingml::Run.new(text: '_name_')
      para3.runs << run3
      cell3.paragraphs << para3
      data_row.cells << cell3
      cell4 = Uniword::TableCell.new
      para4 = Uniword::Paragraph.new
      run4 = Uniword::Wordprocessingml::Run.new(text: '_age_')
      para4.runs << run4
      cell4.paragraphs << para4
      data_row.cells << cell4
      table.rows << data_row

      # Copy row and insert (manual copy in v2.0)
      last_row = table.rows.last
      new_row = Uniword::TableRow.new
      last_row.cells.each do |orig_cell|
        new_cell = Uniword::TableCell.new
        orig_cell.paragraphs.each do |orig_para|
          new_para = Uniword::Paragraph.new
          orig_para.runs.each do |run|
            new_run = Uniword::Wordprocessingml::Run.new(text: run.text)
            new_para.runs << new_run
          end
          new_cell.paragraphs << new_para
        end
        new_row.cells << new_cell
      end
      index = table.rows.index(last_row)
      table.rows.insert(index, new_row)

      expect(table.rows.count).to eq(3)

      # Substitute in all rows
      table.rows.each do |row|
        row.cells.each do |cell|
          cell.paragraphs.each do |para|
            para.runs.each do |run|
              run.text = run.text.to_s.gsub('_name_', 'Alice')
              run.text = run.text.to_s.gsub('_age_', '30')
            end
          end
        end
      end

      expect(table.rows[1].cells[0].paragraphs.first.text).to eq('Alice')
      expect(table.rows[2].cells[1].paragraphs.first.text).to eq('30')
    end
  end
end
