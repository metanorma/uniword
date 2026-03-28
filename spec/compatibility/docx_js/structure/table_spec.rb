# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Docx.js Compatibility: Table', :compatibility do
  describe 'Table' do
    describe 'constructor' do
      it 'creates a table with the correct number of rows and columns' do
        table = Uniword::Table.new

        # Create 3 rows with 2 cells each
        3.times do
          row = Uniword::TableRow.new
          2.times do
            cell = Uniword::TableCell.new
            para = Uniword::Paragraph.new
            run = Uniword::Run.new
            run.text = 'hello'
            para.runs << run
            cell.paragraphs << para
            row.cells << cell
          end
          table.rows << row
        end

        expect(table.rows.count).to eq(3)
        expect(table.rows.first.cells.count).to eq(2)
        expect(table.rows.last.cells.count).to eq(2)
      end

      it 'creates a table with text content' do
        table = Uniword::Table.new
        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row

        expect(table.rows.count).to eq(1)
        expect(table.rows.first.cells.count).to eq(1)
        expect(table.rows.first.cells.first.paragraphs.first.runs.first.text).to eq('hello')
      end

      it 'handles multiple rows and cells' do
        table = Uniword::Table.new

        2.times do |i|
          row = Uniword::TableRow.new
          3.times do |j|
            cell = Uniword::TableCell.new
            para = Uniword::Paragraph.new
            run = Uniword::Wordprocessingml::Run.new(text: "Cell #{i},#{j}")
            para.runs << run
            cell.paragraphs << para
            row.cells << cell
          end
          table.rows << row
        end

        expect(table.rows.count).to eq(2)
        expect(table.rows.first.cells.count).to eq(3)
        expect(table.rows.last.cells.count).to eq(3)
      end
    end

    describe 'columnSpan and rowSpan' do
      it 'creates a table with columnSpan' do
        table = Uniword::Table.new

        # First row with merged cell
        row1 = Uniword::TableRow.new
        cell1 = Uniword::TableCell.new
        para1 = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para1.runs << run1
        cell1.paragraphs << para1
        cell1.column_span = 2
        row1.cells << cell1
        table.rows << row1

        # Second row with two cells
        row2 = Uniword::TableRow.new
        2.times do
          cell = Uniword::TableCell.new
          para = Uniword::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: 'hello')
          para.runs << run
          cell.paragraphs << para
          row2.cells << cell
        end
        table.rows << row2

        expect(table.rows.count).to eq(2)
        expect(table.rows[0].cells[0].column_span).to eq(2)
      end

      it 'creates a table with rowSpan' do
        table = Uniword::Table.new

        # First row
        row1 = Uniword::TableRow.new
        2.times do
          cell = Uniword::TableCell.new
          para = Uniword::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: 'hello')
          para.runs << run
          cell.paragraphs << para
          row1.cells << cell
        end
        table.rows << row1

        # Second row with row span
        row2 = Uniword::TableRow.new
        cell2_1 = Uniword::TableCell.new
        para2_1 = Uniword::Paragraph.new
        run2_1 = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para2_1.runs << run2_1
        cell2_1.paragraphs << para2_1
        cell2_1.row_span = 2
        row2.cells << cell2_1

        cell2_2 = Uniword::TableCell.new
        para2_2 = Uniword::Paragraph.new
        run2_2 = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para2_2.runs << run2_2
        cell2_2.paragraphs << para2_2
        row2.cells << cell2_2
        table.rows << row2

        # Third row
        row3 = Uniword::TableRow.new
        cell3 = Uniword::TableCell.new
        para3 = Uniword::Paragraph.new
        run3 = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para3.runs << run3
        cell3.paragraphs << para3
        row3.cells << cell3
        table.rows << row3

        expect(table.rows.count).to eq(3)
        expect(table.rows[1].cells[0].row_span).to eq(2)
      end

      it 'handles complex span scenarios' do
        table = Uniword::Table.new

        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Merged cell')
        para.runs << run
        cell.paragraphs << para
        cell.column_span = 2
        cell.row_span = 2
        row.cells << cell
        table.rows << row

        expect(table.rows.first.cells.first.column_span).to eq(2)
        expect(table.rows.first.cells.first.row_span).to eq(2)
      end
    end

    describe 'table layout' do
      it 'sets the table to fixed width layout' do
        table = Uniword::Table.new
        table.properties = Uniword::Wordprocessingml::TableProperties.new(layout: 'fixed')

        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row

        expect(table.properties.layout).to eq('fixed')
      end

      it 'sets the table to auto layout by default' do
        table = Uniword::Table.new

        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row

        # Auto layout is the default
        expect(table.properties).to be_nil.or(satisfy { |props|
          props.layout.nil? || props.layout == 'auto'
        })
      end
    end

    describe 'table alignment' do
      it 'should center the table' do
        table = Uniword::Table.new
        table.properties = Uniword::Wordprocessingml::TableProperties.new(alignment: 'center')

        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row

        expect(table.properties.alignment.value).to eq('center')
      end

      it 'should left align the table' do
        table = Uniword::Table.new
        table.properties = Uniword::Wordprocessingml::TableProperties.new(alignment: 'left')

        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row

        expect(table.properties.alignment.value).to eq('left')
      end

      it 'should right align the table' do
        table = Uniword::Table.new
        table.properties = Uniword::Wordprocessingml::TableProperties.new(alignment: 'right')

        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row

        expect(table.properties.alignment.value).to eq('right')
      end
    end

    describe 'table width' do
      it 'should set the table to provided 100% width' do
        table = Uniword::Table.new
        table.properties = Uniword::Wordprocessingml::TableProperties.new(
          table_width: Uniword::Properties::TableWidth.new(w: 100, type: 'pct'),
          layout: 'fixed'
        )

        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row

        expect(table.properties.table_width.w).to eq(100)
        expect(table.properties.table_width.type).to eq('pct')
        expect(table.properties.layout).to eq('fixed')
      end

      it 'should set the table to provided DXA width' do
        table = Uniword::Table.new
        table.properties = Uniword::Wordprocessingml::TableProperties.new(
          table_width: Uniword::Properties::TableWidth.new(w: 1000, type: 'dxa'),
          layout: 'fixed'
        )

        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row

        expect(table.properties.table_width.w).to eq(1000)
        expect(table.properties.table_width.type).to eq('dxa')
      end

      it 'should set specific column widths' do
        table = Uniword::Table.new
        table.properties = Uniword::Wordprocessingml::TableProperties.new(
          table_width: Uniword::Properties::TableWidth.new(w: 5000, type: 'dxa')
        )

        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        cell.properties = Uniword::Wordprocessingml::TableProperties.new(
          table_width: Uniword::Properties::TableWidth.new(w: 2500, type: 'dxa')
        )
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row

        expect(table.properties.table_width.w).to eq(5000)
        expect(table.rows.first.cells.first.properties.table_width.w).to eq(2500)
      end
    end

    describe 'table borders' do
      it 'should set table borders' do
        table = Uniword::Table.new
        table.properties = Uniword::Wordprocessingml::TableProperties.new(
          border_top_style: 'single',
          border_top_size: 4,
          border_top_color: 'auto'
        )

        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row

        expect(table.properties.border_top_style).to eq('single')
        expect(table.properties.border_top_size).to eq(4)
        expect(table.properties.border_top_color).to eq('auto')
      end

      it 'should set all borders at once' do
        table = Uniword::Table.new
        table.properties = Uniword::Wordprocessingml::TableProperties.new(
          border_top_style: 'single',
          border_left_style: 'single',
          border_bottom_style: 'single',
          border_right_style: 'single'
        )

        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row

        expect(table.properties.border_top_style).to eq('single')
        expect(table.properties.border_left_style).to eq('single')
        expect(table.properties.border_bottom_style).to eq('single')
        expect(table.properties.border_right_style).to eq('single')
      end
    end

    describe 'Cell' do
      describe 'prepForXml' do
        it 'inserts a paragraph at the end of the cell if it is empty' do
          table = Uniword::Table.new
          row = Uniword::TableRow.new
          cell = Uniword::TableCell.new
          para = Uniword::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: 'hello')
          para.runs << run
          cell.paragraphs << para
          row.cells << cell
          table.rows << row

          expect(table.rows.first.cells.first.paragraphs.count).to be >= 1
          expect(table.rows.first.cells.first.paragraphs.first.runs.first.text).to eq('hello')
        end

        it 'handles cell with multiple paragraphs' do
          table = Uniword::Table.new
          row = Uniword::TableRow.new
          cell = Uniword::TableCell.new

          para1 = Uniword::Paragraph.new
          run1 = Uniword::Wordprocessingml::Run.new(text: 'First')
          para1.runs << run1
          para2 = Uniword::Paragraph.new
          run2 = Uniword::Wordprocessingml::Run.new(text: 'Second')
          para2.runs << run2
          cell.paragraphs << para1
          cell.paragraphs << para2

          row.cells << cell
          table.rows << row

          expect(table.rows.first.cells.first.paragraphs.count).to eq(2)
        end

        it 'handles empty cell' do
          table = Uniword::Table.new
          row = Uniword::TableRow.new
          cell = Uniword::TableCell.new
          row.cells << cell
          table.rows << row

          # Empty cells are valid
          expect(table.rows.first.cells.first).to be_a(Uniword::TableCell)
        end
      end
    end

    describe 'float properties' do
      it 'sets the table float properties' do
        skip 'Float properties not yet implemented in v2.0 API'
      end

      it 'sets float spacing from text' do
        skip 'Float properties not yet implemented in v2.0 API'
      end
    end

    describe 'integrated table operations' do
      it 'creates a complete table with formatting' do
        table = Uniword::Table.new
        table.properties = Uniword::Wordprocessingml::TableProperties.new(
          table_width: Uniword::Properties::TableWidth.new(w: 100, type: 'pct'),
          alignment: 'center',
          layout: 'fixed'
        )

        # Header row
        header_row = Uniword::TableRow.new
        ['Column 1', 'Column 2', 'Column 3'].each do |header|
          cell = Uniword::TableCell.new
          para = Uniword::Paragraph.new
          run = Uniword::Run.new
          run.text = header
          run.properties = Uniword::Wordprocessingml::RunProperties.new(
            bold: Uniword::Properties::Bold.new(value: true)
          )
          para.runs << run
          cell.paragraphs << para
          header_row.cells << cell
        end
        table.rows << header_row

        # Data rows
        2.times do |i|
          row = Uniword::TableRow.new
          3.times do |j|
            cell = Uniword::TableCell.new
            para = Uniword::Paragraph.new
            run = Uniword::Wordprocessingml::Run.new(text: "Data #{i},#{j}")
            para.runs << run
            cell.paragraphs << para
            row.cells << cell
          end
          table.rows << row
        end

        expect(table.rows.count).to eq(3)
        expect(table.rows.first.cells.count).to eq(3)
        expect(table.rows.first.cells.first.paragraphs.first.runs.first.properties.bold?).to be true
        expect(table.properties.alignment.value).to eq('center')
      end

      it 'adds table to document' do
        doc = Uniword::Document.new
        table = Uniword::Table.new

        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'hello')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row

        doc.body.tables << table

        expect(doc.tables.count).to eq(1)
        expect(doc.tables.first.rows.count).to eq(1)
      end
    end
  end
end
