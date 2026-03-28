# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe 'Docxjs Rendering Compatibility: Format Correctness', :compatibility do
  describe 'Text Rendering' do
    describe 'basic text properties' do
      it 'should render bold text correctly' do
        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Builder::RunBuilder.new.text('Bold text').bold.build
        para.runs << run
        doc.body.paragraphs << para

        para = doc.body.paragraphs.first
        run = para.runs.first
        expect(run.properties&.bold&.value == true).to be true
        expect(run.text).to eq('Bold text')
      end

      it 'should render italic text correctly' do
        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Builder::RunBuilder.new.text('Italic text').italic.build
        para.runs << run
        doc.body.paragraphs << para

        run = doc.body.paragraphs.first.runs.first
        expect(run.properties&.italic&.value == true).to be true
      end

      it 'should render text with font color' do
        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Builder::RunBuilder.new.text('Red text').color('FF0000').build
        para.runs << run
        doc.body.paragraphs << para

        run = doc.body.paragraphs.first.runs.first
        expect(run.properties&.color&.value).to eq('FF0000')
      end

      it 'should render text with font size' do
        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Builder::RunBuilder.new.text('Large text').size(24).build
        para.runs << run
        doc.body.paragraphs << para

        run = doc.body.paragraphs.first.runs.first
        # RunBuilder.size takes points, stores as half-points (points * 2)
        expect(run.properties&.size&.value).to eq(48)
      end

      it 'should render text with font family' do
        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Builder::RunBuilder.new.text('Arial text').font('Arial').build
        para.runs << run
        doc.body.paragraphs << para

        run = doc.body.paragraphs.first.runs.first
        expect(run.properties&.font).to eq('Arial')
      end
    end

    describe 'text combinations' do
      it 'should handle multiple formatting in single run' do
        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Builder::RunBuilder.new
              .text('Formatted')
              .bold
              .italic
              .underline
              .color('0000FF')
              .build
        para.runs << run
        doc.body.paragraphs << para

        run = doc.body.paragraphs.first.runs.first
        expect(run.properties&.bold&.value == true).to be true
        expect(run.properties&.italic&.value == true).to be true
        expect(run.properties&.underline && run.properties.underline != 'none').to be true
        expect(run.properties&.color&.value).to eq('0000FF')
      end

      it 'should handle multiple runs with different formatting' do
        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Normal ')
        para.runs << run1
        run2 = Uniword::Builder::RunBuilder.new.text('Bold').bold.build
        para.runs << run2
        run3 = Uniword::Builder::RunBuilder.new.text(' Italic').italic.build
        para.runs << run3
        doc.body.paragraphs << para

        runs = doc.body.paragraphs.first.runs
        expect(runs.count).to eq(3)
        expect(runs[1].properties&.bold&.value == true).to be true
        expect(runs[2].properties&.italic&.value == true).to be true
      end
    end

    describe 'white space handling' do
      it 'should preserve spaces in text' do
        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Text  with   spaces')
        para.runs << run
        doc.body.paragraphs << para

        expect(doc.body.paragraphs.first.text).to eq('Text  with   spaces')
      end

      it 'should handle leading spaces' do
        skip 'Leading space preservation not yet implemented'

        doc = Uniword::Document.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: '  Leading spaces')
        para.runs << run
        doc.body.paragraphs << para

        expect(doc.body.paragraphs.first.text).to eq('  Leading spaces')
      end

      it 'should handle trailing spaces' do
        skip 'Trailing space preservation not yet implemented'

        doc = Uniword::Document.new
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Trailing spaces  ')
        para.runs << run
        doc.body.paragraphs << para

        expect(doc.body.paragraphs.first.text).to eq('Trailing spaces  ')
      end
    end
  end

  describe 'Underline Rendering' do
    it 'should render single underline' do
      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Builder::RunBuilder.new.text('Single underline').underline('single').build
      para.runs << run
      doc.body.paragraphs << para

      run = doc.body.paragraphs.first.runs.first
      expect(run.properties&.underline&.value).to eq('single')
    end

    it 'should render double underline' do
      skip 'Double underline not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Builder::RunBuilder.new.text('Double underline').underline('double').build
      para.runs << run
      doc.body.paragraphs << para

      expect(doc.body.paragraphs.first.runs.first.underline).to eq('double')
    end

    it 'should render dotted underline' do
      skip 'Dotted underline not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Builder::RunBuilder.new.text('Dotted underline').underline('dotted').build
      para.runs << run
      doc.body.paragraphs << para

      expect(doc.body.paragraphs.first.runs.first.underline).to eq('dotted')
    end

    it 'should render dashed underline' do
      skip 'Dashed underline not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Builder::RunBuilder.new.text('Dashed underline').underline('dashed').build
      para.runs << run
      doc.body.paragraphs << para

      expect(doc.body.paragraphs.first.runs.first.underline).to eq('dashed')
    end

    it 'should render wavy underline' do
      skip 'Wavy underline not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Builder::RunBuilder.new.text('Wavy underline').underline('wave').build
      para.runs << run
      doc.body.paragraphs << para

      expect(doc.body.paragraphs.first.runs.first.underline).to eq('wave')
    end
  end

  describe 'Break Rendering' do
    describe 'line breaks' do
      it 'should render text wrapping breaks' do
        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Line 1')
        para.runs << run1
        # Use Break object for line breaks
        br_run = Uniword::Wordprocessingml::Run.new
        br_run.break = Uniword::Wordprocessingml::Break.new(type: 'line')
        para.runs << br_run
        run2 = Uniword::Wordprocessingml::Run.new(text: 'Line 2')
        para.runs << run2
        doc.body.paragraphs << para

        para = doc.body.paragraphs.first
        break_runs = para.runs.select { |r| r.break }
        expect(break_runs.count).to eq(1)
      end

      it 'should render page breaks' do
        skip 'Page breaks not yet fully implemented'

        doc = Uniword::Document.new

        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Page 1')
        para.runs << run
        doc.body.paragraphs << para
        doc.add_page_break
        para2 = Uniword::Paragraph.new
        run2 = Uniword::Wordprocessingml::Run.new(text: 'Page 2')
        para2.runs << run2
        doc.body.paragraphs << para2

        expect(doc.page_breaks.count).to eq(1)
      end
    end
  end

  describe 'Table Rendering' do
    describe 'basic table structure' do
      it 'should render simple tables' do
        doc = Uniword::Document.new

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
        table.rows << row
        doc.body.tables << table

        table = doc.body.tables.first
        expect(table.rows.count).to eq(1)
        expect(table.rows.first.cells.count).to eq(2)
      end

      it 'should render table borders' do
        skip 'Table borders not yet fully implemented'

        doc = Uniword::Document.new

        table = Uniword::Table.new
        table.borders = {
          top: { style: 'single', size: 4 },
          bottom: { style: 'single', size: 4 },
          left: { style: 'single', size: 4 },
          right: { style: 'single', size: 4 }
        }
        doc.body.tables << table

        expect(doc.body.tables.first.borders).not_to be_nil
      end

      it 'should render cell spanning' do
        doc = Uniword::Document.new

        table = Uniword::Table.new
        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        cell.column_span = 2
        para = Uniword::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Span 2')
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row
        doc.body.tables << table

        cell = doc.body.tables.first.rows.first.cells.first
        expect(cell.column_span).to eq(2)
      end

      it 'should render vertical merging' do
        skip 'Vertical merging not yet fully implemented'

        doc = Uniword::Document.new

        table = Uniword::Table.new
        row1 = Uniword::TableRow.new
        cell1 = Uniword::TableCell.new(vertical_merge: 'restart')
        para1 = Uniword::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Merged')
        para1.runs << run1
        cell1.paragraphs << para1
        row1.cells << cell1
        table.rows << row1
        row2 = Uniword::TableRow.new
        cell2 = Uniword::TableCell.new(vertical_merge: 'continue')
        para2 = Uniword::Paragraph.new
        run2 = Uniword::Wordprocessingml::Run.new(text: '')
        para2.runs << run2
        cell2.paragraphs << para2
        row2.cells << cell2
        table.rows << row2
        doc.body.tables << table

        cells = doc.body.tables.first.rows.map { |r| r.cells.first }
        expect(cells[0].vertical_merge).to eq('restart')
        expect(cells[1].vertical_merge).to eq('continue')
      end
    end
  end

  describe 'Line Spacing Rendering' do
    it 'should render single line spacing' do
      skip 'Line spacing not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Single spacing')
      para.runs << run
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder.spacing(line: 240)
      doc.body.paragraphs << para

      expect(doc.body.paragraphs.first.properties&.spacing&.line).to eq(240)
    end

    it 'should render 1.5 line spacing' do
      skip 'Line spacing not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: '1.5 spacing')
      para.runs << run
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder.spacing(line: 360)
      doc.body.paragraphs << para

      expect(doc.body.paragraphs.first.properties&.spacing&.line).to eq(360)
    end

    it 'should render double line spacing' do
      skip 'Line spacing not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Double spacing')
      para.runs << run
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder.spacing(line: 480)
      doc.body.paragraphs << para

      expect(doc.body.paragraphs.first.properties&.spacing&.line).to eq(480)
    end

    it 'should render exact line height' do
      skip 'Exact line height not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Exact height')
      para.runs << run
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder.spacing(line: 20 * 20, rule: 'exact') # 20 points in twips
      doc.body.paragraphs << para

      para = doc.body.paragraphs.first
      expect(para.properties&.spacing&.line).to eq(400)
      expect(para.properties&.spacing&.line_rule).to eq('exact')
    end

    it 'should render at least line height' do
      skip 'At least line height not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'At least height')
      para.runs << run
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder.spacing(line: 18 * 20, rule: 'atLeast') # 18 points in twips
      doc.body.paragraphs << para

      para = doc.body.paragraphs.first
      expect(para.properties&.spacing&.line_rule).to eq('atLeast')
    end
  end

  describe 'Equation Rendering' do
    it 'should render simple equations' do
      skip 'Equation rendering not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      # TODO: add_equation moved to Builder API; not yet implemented
      skip 'add_equation moved to Builder API'
      doc.body.paragraphs << para

      expect(doc.body.paragraphs.first.equations.count).to eq(1)
    end

    it 'should render fraction equations' do
      skip 'Fraction equations not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      # TODO: add_equation moved to Builder API; not yet implemented
      skip 'add_equation moved to Builder API'
      doc.body.paragraphs << para

      eq = doc.body.paragraphs.first.equations.first
      expect(eq.type).to eq(:fraction)
    end

    it 'should render radical equations' do
      skip 'Radical equations not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      # TODO: add_equation moved to Builder API; not yet implemented
      skip 'add_equation moved to Builder API'
      doc.body.paragraphs << para

      eq = doc.body.paragraphs.first.equations.first
      expect(eq.type).to eq(:radical)
    end
  end

  describe 'Revision Rendering' do
    it 'should render inserted content' do
      skip 'Insertion rendering not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Original ')
      para.runs << run1
      # TODO: add_inserted_run moved to Builder API; not yet implemented
      skip 'add_inserted_run moved to Builder API'
      doc.body.paragraphs << para

      runs = doc.body.paragraphs.first.runs
      expect(runs[1].inserted?).to be true
    end

    it 'should render deleted content' do
      skip 'Deletion rendering not yet implemented'

      doc = Uniword::Document.new

      para = Uniword::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Keep ')
      para.runs << run1
      # TODO: add_deleted_run moved to Builder API; not yet implemented
      skip 'add_deleted_run moved to Builder API'
      doc.body.paragraphs << para

      runs = doc.body.paragraphs.first.runs
      expect(runs[1].deleted?).to be true
    end
  end

  describe 'Format Compatibility' do
    describe 'Office 2007+' do
      it 'should handle OOXML namespaces correctly' do
        skip 'OOXML namespace handling not yet verified'

        # Verify proper namespace handling for:
        # - w: (wordprocessingML)
        # - r: (relationships)
        # - v: (VML)
        # - etc.
      end
    end

    describe 'Legacy formats' do
      it 'should handle doc format conversion' do
        skip 'DOC format not supported'

        # .doc files are binary format
        # Not planning to support directly
      end
    end

    describe 'compatibility mode' do
      it 'should detect document compatibility mode' do
        skip 'Compatibility mode detection not yet implemented'

        # Documents can be in Word 2007, 2010, 2013, 2016 mode
        # Parser should detect and handle appropriately
      end
    end
  end
end
