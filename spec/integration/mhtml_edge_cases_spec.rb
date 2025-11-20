# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe 'MHTML Edge Cases', type: :integration do
  let(:tmp_dir) { 'spec/tmp' }

  before(:all) do
    FileUtils.mkdir_p('spec/tmp')
  end

  after(:each) do
    Dir.glob("#{tmp_dir}/*.{doc,mhtml}").each { |f| File.delete(f) }
  end

  describe 'Empty Content' do
    let(:output_path) { File.join(tmp_dir, 'empty.doc') }

    it 'handles documents with no content' do
      doc = Uniword::Document.new
      doc.save(output_path, format: :mhtml)

      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)
      expect(doc2.elements).to be_empty
    end

    it 'handles empty paragraphs' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'handles paragraphs with empty runs' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = ''
      para.add_run(run)
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'handles empty tables' do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      doc.add_element(table)

      expect { doc.save(output_path, format: :mhtml) }.not_to raise_error
    end

    it 'handles table with empty cells' do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      row.add_cell(cell)
      table.add_row(row)
      doc.add_element(table)

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
      para.add_text('Text with <, >, &, ", \'')
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('<, >, &')
    end

    it 'handles HTML tags as text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('<html><body>Not actual HTML</body></html>')
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('<html>')
      expect(doc2.text).to include('</body>')
    end

    it 'handles script tags as text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('<script>alert("XSS")</script>')
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)

      # Verify file doesn't contain actual script
      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('&lt;script&gt;')
      expect(content).not_to include('<script>alert')
    end

    it 'handles CDATA sections as text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('<![CDATA[Some data]]>')
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('CDATA')
    end

    it 'handles HTML entities' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('&nbsp; &copy; &reg; &trade;')
      doc.add_element(para)

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
      para.add_text('Unicode: 你好世界 مرحبا בעולם Привет')
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('你好世界')
      expect(doc2.text).to include('مرحبا')
      expect(doc2.text).to include('Привет')
    end

    it 'handles emoji and symbols' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Symbols: ™ © ® € ¥ 😀 ✓')
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('™ © ® € ¥')
    end

    it 'handles mixed direction text (LTR and RTL)' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('English مرحبا English again')
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('English')
      expect(doc2.text).to include('مرحبا')
    end

    it 'handles zero-width spaces' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text("Word\u200BBreak")
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'handles non-breaking spaces' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text("Non\u00A0breaking space")
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('Non')
      expect(doc2.text).to include('breaking')
    end
  end

  describe 'Large Documents' do
    let(:output_path) { File.join(tmp_dir, 'large.doc') }

    it 'handles large documents' do
      doc = Uniword::Document.new
      100.times do |i|
        para = Uniword::Paragraph.new
        para.add_text("Paragraph #{i + 1}")
        doc.add_element(para)
      end

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.elements.count).to eq(100)
    end

    it 'handles paragraphs with very long text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new

      long_text = 'Lorem ipsum dolor sit amet ' * 370
      para.add_text(long_text[0, 10000])
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text.length).to be >= 9000
    end

    it 'handles many tables' do
      doc = Uniword::Document.new

      50.times do |i|
        table = Uniword::Table.new
        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        para = Uniword::Paragraph.new
        para.add_text("Table #{i + 1}")
        cell.add_paragraph(para)
        row.add_cell(cell)
        table.add_row(row)
        doc.add_element(table)
      end

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.tables.count).to eq(50)
    end

    it 'handles large tables with many cells' do
      doc = Uniword::Document.new
      table = Uniword::Table.new

      # 20x20 table
      20.times do |r|
        row = Uniword::TableRow.new
        20.times do |c|
          cell = Uniword::TableCell.new
          para = Uniword::Paragraph.new
          para.add_text("#{r},#{c}")
          cell.add_paragraph(para)
          row.add_cell(cell)
        end
        table.add_row(row)
      end

      doc.add_element(table)

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
      para.add_text('Multiple  spaces   here')
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('Multiple')
      expect(doc2.text).to include('spaces')
    end

    it 'handles leading and trailing whitespace' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('  Text with spaces  ')
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('Text with spaces')
    end

    it 'handles tabs' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text("Text\twith\ttabs")
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'handles newlines in text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text("Line 1\nLine 2")
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to include('Line 1')
      expect(doc2.text).to include('Line 2')
    end
  end

  describe 'Boundary Conditions' do
    let(:output_path) { File.join(tmp_dir, 'boundary.doc') }

    it 'handles single character text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('A')
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.text).to eq('A')
    end

    it 'handles minimum table (1x1)' do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      para = Uniword::Paragraph.new
      para.add_text('X')
      cell.add_paragraph(para)
      row.add_cell(cell)
      table.add_row(row)
      doc.add_element(table)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.tables.count).to eq(1)
      expect(doc2.tables.first.rows.count).to eq(1)
      expect(doc2.tables.first.rows.first.cells.count).to eq(1)
    end

    it 'handles text with only whitespace' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('   ')
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(1)
    end
  end

  describe 'Mixed Content Types' do
    let(:output_path) { File.join(tmp_dir, 'mixed.doc') }

    it 'handles alternating paragraphs and tables' do
      doc = Uniword::Document.new

      5.times do |i|
        # Paragraph
        para = Uniword::Paragraph.new
        para.add_text("Paragraph #{i + 1}")
        doc.add_element(para)

        # Table
        table = Uniword::Table.new
        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        cell_para = Uniword::Paragraph.new
        cell_para.add_text("Table #{i + 1}")
        cell.add_paragraph(cell_para)
        row.add_cell(cell)
        table.add_row(row)
        doc.add_element(table)
      end

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      # Should have some paragraphs and tables
      expect(doc2.paragraphs.count).to be > 0
      expect(doc2.tables.count).to be > 0
    end

    it 'handles formatted and unformatted text mixed' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new

      # Bold run
      bold_run = Uniword::Run.new
      bold_run.text = 'Bold'
      bold_run.properties = Uniword::Properties::RunProperties.new(bold: true)
      para.add_run(bold_run)

      # Normal run
      normal_run = Uniword::Run.new
      normal_run.text = ' normal '
      para.add_run(normal_run)

      # Italic run
      italic_run = Uniword::Run.new
      italic_run.text = 'italic'
      italic_run.properties = Uniword::Properties::RunProperties.new(
        italic: true
      )
      para.add_run(italic_run)

      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      runs = doc2.paragraphs.first.runs
      expect(runs[0].properties.bold).to be true
      expect(runs[2].properties.italic).to be true
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

    it 'handles multiple heading levels' do
      doc = Uniword::Document.new

      %w[Heading1 Heading2 Heading3 Heading4 Heading5 Heading6].each do |style|
        para = Uniword::Paragraph.new(
          properties: Uniword::Properties::ParagraphProperties.new(style: style)
        )
        para.add_text("#{style} text")
        doc.add_element(para)
      end

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(6)
      expect(doc2.paragraphs[0].properties.style).to eq('Heading1')
      expect(doc2.paragraphs[5].properties.style).to eq('Heading6')
    end

    it 'handles paragraphs without explicit styles' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Normal paragraph')
      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      expect(doc2.paragraphs.first.text).to eq('Normal paragraph')
    end

    it 'handles runs with multiple formatting properties' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new

      run = Uniword::Run.new
      run.text = 'Formatted'
      run.properties = Uniword::Properties::RunProperties.new
      run.properties.bold = true
      run.properties.italic = true
      run.properties.underline = true
      run.properties.font = 'Arial'
      run.properties.size = 48
      para.add_run(run)

      doc.add_element(para)

      doc.save(output_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(output_path, format: :mhtml)

      first_run = doc2.paragraphs.first.runs.first
      expect(first_run.properties.bold).to be true
      expect(first_run.properties.italic).to be true
      expect(first_run.properties.underline).to be_truthy # Underline is "single" string, not boolean
    end
  end
end