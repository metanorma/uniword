# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'docx gem API Compatibility' do
  describe 'Document operations' do
    it 'supports Document.open(path)' do
      doc = Uniword.load('spec/fixtures/basic.docx')
      expect(doc).to be_a(Uniword::Document)
    end

    it 'supports doc.text to get plain text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Hello World')
      doc.body.paragraphs << para

      expect(doc.text).to eq('Hello World')
    end

    it 'supports doc.to_html for HTML export' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Hello World')
      doc.body.paragraphs << para

      html = doc.to_html
      expect(html).to be_a(String)
      expect(html).to include('<p>')
      expect(html).to include('Hello World')
    end

    it 'supports doc.stream for StringIO output' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Hello World')
      doc.body.paragraphs << para

      stream = doc.stream
      expect(stream).to be_a(StringIO)
      expect(stream.size).to be > 0
    end

    it 'supports doc.paragraphs' do
      doc = Uniword::Document.new
      para1 = Uniword::Paragraph.new.add_text('Para 1')
      para2 = Uniword::Paragraph.new.add_text('Para 2')
      doc.body.paragraphs << para
      doc.body.paragraphs << para

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
      para.add_text('Hello')
      para.add_text(' World')

      expect(para.text).to eq('Hello World')
    end

    it 'supports paragraph.text= to set content' do
      para = Uniword::Paragraph.new
      para.add_text('Old text')

      para.text = 'New text'
      expect(para.text).to eq('New text')
      expect(para.runs.count).to eq(1)
    end

    it 'supports paragraph.to_html' do
      para = Uniword::Paragraph.new
      para.add_text('Hello World')

      html = para.to_html
      expect(html).to include('<p>')
      expect(html).to include('Hello World')
      expect(html).to include('</p>')
    end

    it 'supports paragraph.remove!' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Remove me')
      doc.body.paragraphs << para

      expect(doc.paragraphs.count).to eq(1)
      para.remove!
      expect(doc.paragraphs.count).to eq(0)
    end

    it 'supports paragraph.each_text_run' do
      para = Uniword::Paragraph.new
      para.add_text('Hello')
      para.add_text(' World')

      texts = []
      para.each_text_run { |run| texts << run.text }
      expect(texts).to eq(['Hello', ' World'])
    end

    it 'supports paragraph.style' do
      para = Uniword::Paragraph.new
      para.set_style('Heading1')

      expect(para.style).to eq('Heading1')
    end

    it 'supports paragraph.alignment' do
      para = Uniword::Paragraph.new
      para.align('center')

      expect(para.alignment).to eq('center')
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
      run.substitute(/[A-Z]+/, 'World')
      expect(run.text).to eq('Hello World')
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
      run = Uniword::Run.new(text: 'Bold',
                             properties: Uniword::Wordprocessingml::RunProperties.new(bold: true))
      expect(run.bold?).to be true

      plain_run = Uniword::Run.new(text: 'Plain')
      expect(plain_run.bold?).to be false
    end

    it 'supports run.italic?' do
      run = Uniword::Run.new(text: 'Italic',
                             properties: Uniword::Wordprocessingml::RunProperties.new(italic: true))
      expect(run.italic?).to be true
    end

    it 'supports run.underline?' do
      run = Uniword::Run.new(text: 'Underlined',
                             properties: Uniword::Wordprocessingml::RunProperties.new(underline: 'single'))
      expect(run.underline?).to be true
    end

    it 'supports run.strike? / run.striked?' do
      run = Uniword::Run.new(text: 'Strike',
                             properties: Uniword::Wordprocessingml::RunProperties.new(strike: true))
      expect(run.strike?).to be true
      expect(run.striked?).to be true
    end

    it 'supports run.to_html' do
      run = Uniword::Run.new(text: 'Hello',
                             properties: Uniword::Wordprocessingml::RunProperties.new(bold: true))
      html = run.to_html
      expect(html).to include('<strong>')
      expect(html).to include('Hello')
    end

    it 'supports run.font_size' do
      run = Uniword::Run.new(text: 'Text',
                             properties: Uniword::Wordprocessingml::RunProperties.new(size: 24))
      expect(run.font_size).to eq(12) # size is in half-points
    end
  end

  describe 'Table operations' do
    it 'supports table.rows' do
      table = Uniword::Table.new
      row1 = Uniword::TableRow.new
      row2 = Uniword::TableRow.new
      table.add_row(row1)
      table.add_row(row2)

      expect(table.rows.count).to eq(2)
    end

    it 'supports table.row_count' do
      table = Uniword::Table.new
      table.add_row(Uniword::TableRow.new)
      table.add_row(Uniword::TableRow.new)

      expect(table.row_count).to eq(2)
    end

    it 'supports table.column_count' do
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      row.cells << Uniword::TableCell.new.tap do |cell|
        cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell 1') }
      end
      row.cells << Uniword::TableCell.new.tap do |cell|
        cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell 2') }
      end
      row.cells << Uniword::TableCell.new.tap do |cell|
        cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell 3') }
      end
      table.rows << row

      expect(table.rows.first.cells.count).to eq(3)
    end

    it 'supports table.columns for column-based iteration' do
      table = Uniword::Table.new
      row1 = Uniword::TableRow.new
      row1.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('A1') } }
      row1.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('B1') } }
      table.rows << row1

      row2 = Uniword::TableRow.new
      row2.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('A2') } }
      row2.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('B2') } }
      table.rows << row2

      # Check column content manually
      expect(table.rows.count).to eq(2)
      expect(table.rows.first.cells.count).to eq(2)
      expect(table.rows[0].cells[0].paragraphs.first.text).to eq('A1')
      expect(table.rows[1].cells[0].paragraphs.first.text).to eq('A2')
    end

    it 'supports row.copy to duplicate a row' do
      row = Uniword::TableRow.new
      row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell 1') } }
      row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell 2') } }

      # Create a copy manually (v2.0 doesn't have copy method)
      new_row = Uniword::TableRow.new
      row.cells.each do |orig_cell|
        new_cell = Uniword::TableCell.new
        orig_cell.paragraphs.each do |orig_para|
          new_para = Uniword::Paragraph.new
          orig_para.runs.each do |run|
            new_para.add_text(run.text)
          end
          new_cell.paragraphs << new_para
        end
        new_row.cells << new_cell
      end

      expect(new_row).to be_a(Uniword::TableRow)
      expect(new_row).not_to eq(row)
      expect(new_row.cells.count).to eq(row.cells.count)

      # Verify deep copy
      expect(new_row.cells.first.paragraphs.first.text).to eq('Cell 1')
    end

    it 'supports row.insert_before to insert row before another' do
      table = Uniword::Table.new
      row1 = Uniword::TableRow.new
      row1.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Row 1') } }
      row2 = Uniword::TableRow.new
      row2.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Row 2') } }
      table.rows << row1
      table.rows << row2

      new_row = Uniword::TableRow.new
      new_row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('New Row') } }

      # Insert before row2 (v2.0: use array insert)
      index = table.rows.index(row2)
      table.rows.insert(index, new_row)

      expect(table.rows.count).to eq(3)
      expect(table.rows[1]).to eq(new_row)
      expect(table.rows[2]).to eq(row2)
    end

    it 'supports row.cells' do
      row = Uniword::TableRow.new
      row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell 1') } }
      row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell 2') } }

      expect(row.cells.count).to eq(2)
      expect(row.cells.first).to be_a(Uniword::TableCell)
    end

    it 'supports cell.paragraphs' do
      cell = Uniword::TableCell.new
      cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Text 1') }
      cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Text 2') }

      expect(cell.paragraphs.count).to eq(2)
    end
  end

  describe 'Integration scenarios' do
    it 'supports complex text substitution workflow' do
      doc = Uniword::Document.new

      para1 = Uniword::Paragraph.new
      para1.add_text('Dear _name_,')
      doc.body.paragraphs << para

      para2 = Uniword::Paragraph.new
      para2.add_text('Your total is $__amount__.')
      doc.body.paragraphs << para

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
      header.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Name') } }
      header.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Age') } }
      table.rows << header

      # Add data row
      data_row = Uniword::TableRow.new
      data_row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('_name_') } }
      data_row.cells << Uniword::TableCell.new.tap { |cell| cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('_age_') } }
      table.rows << data_row

      # Copy row and insert (manual copy in v2.0)
      last_row = table.rows.last
      new_row = Uniword::TableRow.new
      last_row.cells.each do |orig_cell|
        new_cell = Uniword::TableCell.new
        orig_cell.paragraphs.each do |orig_para|
          new_para = Uniword::Paragraph.new
          orig_para.runs.each do |run|
            new_para.add_text(run.text)
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
              run.text = run.text.gsub('_name_', 'Alice')
              run.text = run.text.gsub('_age_', '30')
            end
          end
        end
      end

      expect(table.rows[1].cells[0].paragraphs.first.text).to eq('Alice')
      expect(table.rows[2].cells[1].paragraphs.first.text).to eq('30')
    end
  end
end
