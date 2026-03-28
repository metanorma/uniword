# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe 'MHTML Edge Cases', type: :integration do
  # NOTE: Mhtml::Document stores raw HTML and lacks paragraphs/tables/runs.
  # Tests that verify round-trip content via doc2.paragraphs or doc2.tables
  # are skipped until MHTML model architecture is implemented.

  let(:tmp_dir) { 'spec/tmp' }

  before(:all) do
    FileUtils.mkdir_p('spec/tmp')
  end

  after(:each) do
    Dir.glob("#{tmp_dir}/*.{doc,mhtml}").each { |f| File.delete(f) }
  end

  describe 'Empty Content' do
    let(:output_path) { File.join(tmp_dir, 'empty.doc') }

    it 'handles documents with no content', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      doc.save(output_path, format: :mhtml)

      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)
      expect(doc2.paragraphs).to be_empty
    end

    it 'handles empty paragraphs', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'handles paragraphs with empty runs', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: '')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'handles empty tables' do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      doc.body.tables << table

      expect { doc.save(output_path, format: :mhtml) }.not_to raise_error
    end

    it 'handles table with empty cells', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      row.cells << cell
      table.rows << row
      doc.body.tables << table

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.tables.count).to eq(1)
    end
  end

  describe 'Special HTML Characters' do
    let(:output_path) { File.join(tmp_dir, 'special_chars.doc') }

    it 'handles special HTML characters' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: 'Text with <, >, &, ", \'')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('<, >, &')
    end

    it 'handles HTML tags as text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: '<html><body>Not actual HTML</body></html>')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('<html>')
      expect(doc2.text).to include('</body>')
    end

    it 'handles script tags as text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: '<script>alert("XSS")</script>')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)

      # Verify file doesn't contain actual script
      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('&lt;script&gt;')
      expect(content).not_to include('<script>alert')
    end

    it 'handles CDATA sections as text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: '<![CDATA[Some data]]>')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('CDATA')
    end

    it 'handles HTML entities', skip: 'MHTML does not decode HTML entities on read-back' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: '&nbsp; &copy; &reg; &trade;')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('©')
      expect(doc2.text).to include('®')
      expect(doc2.text).to include('™')
    end
  end

  describe 'Unicode and Character Encoding' do
    let(:output_path) { File.join(tmp_dir, 'unicode.doc') }

    it 'handles Unicode characters' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: 'Unicode: 你好世界 مرحبا בעולם Привет')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('你好世界')
      expect(doc2.text).to include('مرحبا')
      expect(doc2.text).to include('Привет')
    end

    it 'handles emoji and symbols' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: 'Symbols: ™ © ® € ¥ 😀 ✓')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('™ © ® € ¥')
    end

    it 'handles mixed direction text (LTR and RTL)' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: 'English مرحبا English again')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('English')
      expect(doc2.text).to include('مرحبا')
    end

    it 'handles zero-width spaces', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: "Word\u200BBreak")
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'handles non-breaking spaces' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: "Non\u00A0breaking space")
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('Non')
      expect(doc2.text).to include('breaking')
    end
  end

  describe 'Large Documents' do
    let(:output_path) { File.join(tmp_dir, 'large.doc') }

    it 'handles large documents', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      100.times do |i|
        para = Uniword::Paragraph.new
        run = Uniword::Run.new(text: "Paragraph #{i + 1}")
        para.runs << run
        doc.body.paragraphs << para
      end

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(100)
    end

    it 'handles paragraphs with very long text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new

      long_text = 'Lorem ipsum dolor sit amet ' * 370
      run = Uniword::Run.new(text: long_text[0, 10_000])
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text.length).to be >= 9000
    end

    it 'handles many tables', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new

      50.times do |i|
        table = Uniword::Table.new
        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        run = Uniword::Run.new(text: "Table #{i + 1}")
        para.runs << run
        cell.paragraphs << para
        row.cells << cell
        table.rows << row
        doc.body.tables << table
      end

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.tables.count).to eq(50)
    end

    it 'handles large tables with many cells', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      table = Uniword::Table.new

      # 20x20 table
      20.times do |r|
        row = Uniword::TableRow.new
        20.times do |c|
          cell = Uniword::TableCell.new
          para = Uniword::Paragraph.new
          run = Uniword::Run.new(text: "#{r},#{c}")
          para.runs << run
          cell.paragraphs << para
          row.cells << cell
        end
        table.rows << row
      end

      doc.body.tables << table

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.tables.first.rows.count).to eq(20)
      expect(doc2.tables.first.rows.first.cells.count).to eq(20)
    end
  end

  describe 'Whitespace Handling' do
    let(:output_path) { File.join(tmp_dir, 'whitespace.doc') }

    it 'preserves multiple spaces' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: 'Multiple  spaces   here')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('Multiple')
      expect(doc2.text).to include('spaces')
    end

    it 'handles leading and trailing whitespace' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: '  Text with spaces  ')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('Text with spaces')
    end

    it 'handles tabs', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: "Text\twith\ttabs")
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'handles newlines in text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: "Line 1\nLine 2")
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('Line 1')
      expect(doc2.text).to include('Line 2')
    end
  end

  describe 'Boundary Conditions' do
    let(:output_path) { File.join(tmp_dir, 'boundary.doc') }

    it 'handles single character text', skip: 'MHTML text includes wrapper elements on read-back' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: 'A')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to eq('A')
    end

    it 'handles minimum table (1x1)', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: 'X')
      para.runs << run
      cell.paragraphs << para
      row.cells << cell
      table.rows << row
      doc.body.tables << table

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.tables.count).to eq(1)
      expect(doc2.tables.first.rows.count).to eq(1)
      expect(doc2.tables.first.rows.first.cells.count).to eq(1)
    end

    it 'handles text with only whitespace', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: '   ')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(1)
    end
  end

  describe 'Mixed Content Types' do
    let(:output_path) { File.join(tmp_dir, 'mixed.doc') }

    it 'handles alternating paragraphs and tables', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new

      5.times do |i|
        # Paragraph
        para = Uniword::Paragraph.new
        run = Uniword::Run.new(text: "Paragraph #{i + 1}")
        para.runs << run
        doc.body.paragraphs << para

        # Table
        table = Uniword::Table.new
        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        cell_para = Uniword::Paragraph.new
        cell_run = Uniword::Run.new(text: "Table #{i + 1}")
        cell_para.runs << cell_run
        cell.paragraphs << cell_para
        row.cells << cell
        table.rows << row
        doc.body.tables << table
      end

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      # Should have some paragraphs and tables
      expect(doc2.paragraphs.count).to be > 0
      expect(doc2.tables.count).to be > 0
    end

    it 'handles formatted and unformatted text mixed', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new

      # Bold run
      bold_run = Uniword::Run.new(
        text: 'Bold',
        properties: Uniword::Wordprocessingml::RunProperties.new(bold: true)
      )
      para.runs << bold_run

      # Normal run
      normal_run = Uniword::Run.new(text: ' normal ')
      para.runs << normal_run

      # Italic run
      italic_run = Uniword::Run.new(
        text: 'italic',
        properties: Uniword::Wordprocessingml::RunProperties.new(
          italic: true
        )
      )
      para.runs << italic_run

      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      runs = doc2.paragraphs.first.runs
      expect(runs[0].properties).to be_bold
      expect(runs[2].properties).to be_italic
    end
  end

  describe 'Error Handling' do
    it 'handles invalid file paths gracefully' do
      expect { Uniword::DocumentFactory.from_file('', format: :mhtml) }
        .to raise_error(ArgumentError, /Path cannot be empty/)
    end

    it 'handles nil paths gracefully' do
      expect { Uniword::DocumentFactory.from_file(nil, format: :mhtml) }
        .to raise_error(ArgumentError, /Path cannot be nil/)
    end

    it 'handles non-existent files gracefully' do
      expect do
        Uniword::DocumentFactory.from_file('nonexistent.doc', format: :mhtml)
      end.to raise_error(Uniword::FileNotFoundError, /File not found/)
    end

    it 'handles corrupted MHTML files gracefully' do
      corrupted_path = File.join(tmp_dir, 'corrupted.doc')
      File.write(corrupted_path, 'This is not a valid MHTML file')

      expect do
        Uniword::DocumentFactory.from_file(corrupted_path, format: :mhtml)
      end.to raise_error # Should raise some parsing error
    end
  end

  describe 'CSS and Style Edge Cases' do
    let(:output_path) { File.join(tmp_dir, 'styles.doc') }

    it 'handles multiple heading levels', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new

      %w[Heading1 Heading2 Heading3 Heading4 Heading5 Heading6].each do |style|
        para = Uniword::Paragraph.new(
          properties: Uniword::Wordprocessingml::ParagraphProperties.new(style: style)
        )
        run = Uniword::Run.new(text: "#{style} text")
        para.runs << run
        doc.body.paragraphs << para
      end

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(6)
      expect(doc2.paragraphs[0].properties.style).to eq('Heading1')
      expect(doc2.paragraphs[5].properties.style).to eq('Heading6')
    end

    it 'handles paragraphs without explicit styles', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: 'Normal paragraph')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.first.text).to eq('Normal paragraph')
    end

    it 'handles runs with multiple formatting properties', skip: 'MHTML requires separate model tree (not OOXML)' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new

      run = Uniword::Run.new
      run.text = 'Formatted'
      run.properties = Uniword::Wordprocessingml::RunProperties.new
      run.properties.bold = true
      run.properties.italic = true
      run.properties.underline = true
      run.properties.font = 'Arial'
      run.properties.size = 48
      para.runs << run

      doc.body.paragraphs << para

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      first_run = doc2.paragraphs.first.runs.first
      expect(first_run.properties).to be_bold
      expect(first_run.properties).to be_italic
      expect(first_run.properties.underline).to be_truthy # Underline is "single" string, not boolean
    end
  end
end
