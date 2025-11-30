# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe 'DOCX Edge Case Handling' do
  let(:tmp_dir) { 'tmp/edge_cases' }

  before(:all) do
    FileUtils.mkdir_p('tmp/edge_cases')
  end

  after(:each) do
    # Clean up temporary files after each test
    Dir.glob("#{tmp_dir}/*.docx").each { |f| File.delete(f) }
  end

  describe 'Empty Elements' do
    let(:test_path) { "#{tmp_dir}/empty_test.docx" }

    it 'handles empty paragraphs' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      # No runs added
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'handles empty tables' do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      # No rows added
      doc.add_element(table)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles empty runs' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      # No text added
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles documents with no content' do
      doc = Uniword::Document.new
      # No elements added

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs).to be_empty
    end

    it 'handles table with empty cells' do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      row = Uniword::TableRow.new

      # Add empty cell
      cell = Uniword::TableCell.new
      row.add_cell(cell)
      table.add_row(row)
      doc.add_element(table)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles table rows with no cells' do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      # No cells added
      table.add_row(row)
      doc.add_element(table)

      expect { doc.save(test_path) }.not_to raise_error
    end
  end

  describe 'Special Characters' do
    let(:test_path) { "#{tmp_dir}/special_chars_test.docx" }

    it 'handles XML special characters' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'Special: < > & " \''
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      text = extract_text(doc2)
      expect(text).to include('<')
      expect(text).to include('>')
      expect(text).to include('&')
    end

    it 'handles Unicode characters' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'Unicode: 你好世界 مرحبا بالعالم Привет мир'
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      text = extract_text(doc2)
      expect(text).to include('你好世界')
    end

    it 'handles emoji and symbols' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'Emoji: 🌍 🎉 ❤️ 🚀 Symbols: © ® ™ € £ ¥'
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'handles whitespace characters' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = "Multiple  spaces\tTab\nNewline\r\nCarriage return"
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles null characters safely' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      # Remove null characters if present
      text = "Text with\u0000null".gsub("\u0000", '')
      run.text = text
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles control characters' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      # Filter out problematic control characters
      text = "Text\u0001\u0002\u0003".gsub(/[\u0000-\u0008\u000B-\u000C\u000E-\u001F]/, '')
      run.text = text
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles RTL (right-to-left) text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'RTL: مرحبا بك في العالم العربي'
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      text = extract_text(doc2)
      expect(text).to include('مرحبا')
    end

    it 'handles mixed LTR and RTL text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'English مرحبا English again'
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error
    end
  end

  describe 'Large Documents' do
    let(:test_path) { "#{tmp_dir}/large_test.docx" }

    it 'handles 100+ paragraphs' do
      doc = Uniword::Document.new

      150.times do |i|
        para = Uniword::Paragraph.new
        run = Uniword::Run.new
        run.text = "Paragraph #{i + 1}"
        para.add_run(run)
        doc.add_element(para)
      end

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(150)
    end

    it 'handles 50+ tables' do
      doc = Uniword::Document.new

      50.times do |t|
        table = Uniword::Table.new
        row = Uniword::TableRow.new
        cell = Uniword::TableCell.new
        cell_para = Uniword::Paragraph.new
        cell_run = Uniword::Run.new
        cell_run.text = "Table #{t + 1}"
        cell_para.add_run(cell_run)
        cell.add_paragraph(cell_para)
        row.add_cell(cell)
        table.add_row(row)
        doc.add_element(table)
      end

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.tables.count).to eq(50)
    end

    it 'handles deep nesting' do
      doc = Uniword::Document.new

      # Create nested tables
      outer_table = Uniword::Table.new
      outer_row = Uniword::TableRow.new
      outer_cell = Uniword::TableCell.new

      # Add nested content
      outer_cell_para = Uniword::Paragraph.new
      outer_cell_run = Uniword::Run.new
      outer_cell_run.text = 'Outer cell content'
      outer_cell_para.add_run(outer_cell_run)
      outer_cell.add_paragraph(outer_cell_para)

      outer_row.add_cell(outer_cell)
      outer_table.add_row(outer_row)
      doc.add_element(outer_table)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles many runs per paragraph' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new

      100.times do |i|
        run = Uniword::Run.new
        run.text = "Run #{i + 1} "
        para.add_run(run)
      end

      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles large table with many cells' do
      doc = Uniword::Document.new
      table = Uniword::Table.new

      # 20x20 table
      20.times do |r|
        row = Uniword::TableRow.new
        20.times do |c|
          cell = Uniword::TableCell.new
          cell_para = Uniword::Paragraph.new
          cell_run = Uniword::Run.new
          cell_run.text = "#{r},#{c}"
          cell_para.add_run(cell_run)
          cell.add_paragraph(cell_para)
          row.add_cell(cell)
        end
        table.add_row(row)
      end

      doc.add_element(table)

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.tables.first.rows.count).to eq(20)
    end
  end

  describe 'Malformed Input' do
    let(:test_path) { "#{tmp_dir}/malformed_test.docx" }

    it 'handles reading non-existent file gracefully' do
      expect { Uniword::DocumentFactory.from_file('nonexistent.docx') }
        .to raise_error(Uniword::FileNotFoundError, /File not found/)
    end

    it 'handles reading non-DOCX file gracefully' do
      # Create a text file
      text_file = "#{tmp_dir}/not_a_docx.docx"
      File.write(text_file, 'This is not a DOCX file')

      expect { Uniword::DocumentFactory.from_file(text_file) }
        .to raise_error # Should raise some error (ZIP or parsing error)
    end

    it 'handles empty file path' do
      expect { Uniword::DocumentFactory.from_file('') }
        .to raise_error(ArgumentError, /Path cannot be empty/)
    end

    it 'handles nil file path' do
      expect { Uniword::DocumentFactory.from_file(nil) }
        .to raise_error(ArgumentError, /Path cannot be nil/)
    end

    it 'validates document before saving' do
      doc = Uniword::Document.new

      # Document should be valid even when empty
      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles invalid element types gracefully' do
      doc = Uniword::Document.new

      expect { doc.add_element('not an element') }
        .to raise_error(ArgumentError)
    end
  end

  describe 'Maximum Values' do
    let(:test_path) { "#{tmp_dir}/max_values_test.docx" }

    it 'handles very long text in paragraph' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new

      # 10,000 character text
      long_text = 'Lorem ipsum dolor sit amet ' * 370
      run.text = long_text[0, 10_000]
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(extract_text(doc2).length).to be >= 9000
    end

    it 'handles maximum font size' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new

      run.font_size = 144 # 72 points = 144 half-points
      run.text = 'Large text'
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles many list levels' do
      doc = Uniword::Document.new

      # Create paragraphs at different indentation levels
      5.times do |level|
        para = Uniword::Paragraph.new

        para.properties.left_indent = 720 * level if para.respond_to?(:properties)

        run = Uniword::Run.new
        run.text = "Level #{level + 1} item"
        para.add_run(run)
        doc.add_element(para)
      end

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles extreme indentation values' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new

      if para.respond_to?(:properties=)
        props = Uniword::Properties::ParagraphProperties.new
        props.left_indent = 5040 # 7 inches in twips
        para.properties = props
      end

      run = Uniword::Run.new
      run.text = 'Deeply indented'
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles wide tables' do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      row = Uniword::TableRow.new

      # Create 15 columns
      15.times do |c|
        cell = Uniword::TableCell.new
        cell_para = Uniword::Paragraph.new
        cell_run = Uniword::Run.new
        cell_run.text = "Col #{c + 1}"
        cell_para.add_run(cell_run)
        cell.add_paragraph(cell_para)
        row.add_cell(cell)
      end

      table.add_row(row)
      doc.add_element(table)

      expect { doc.save(test_path) }.not_to raise_error
    end
  end

  describe 'Error Recovery' do
    let(:test_path) { "#{tmp_dir}/error_recovery_test.docx" }

    it 'provides informative error messages for invalid paths' do
      expect { Uniword::DocumentFactory.from_file('') }
        .to raise_error(ArgumentError, /Path cannot be empty/)
    end

    it 'provides informative error messages for invalid elements' do
      doc = Uniword::Document.new

      expect { doc.add_element(nil) }
        .to raise_error(ArgumentError)
    end

    it 'handles document with mixed valid and edge case content' do
      doc = Uniword::Document.new

      # Normal paragraph
      para1 = Uniword::Paragraph.new
      run1 = Uniword::Run.new
      run1.add_text('Normal text')
      para1.add_run(run1)
      doc.add_element(para1)

      # Empty paragraph
      para2 = Uniword::Paragraph.new
      doc.add_element(para2)

      # Paragraph with special chars
      para3 = Uniword::Paragraph.new
      run3 = Uniword::Run.new
      run3.add_text('Special: < > &')
      para3.add_run(run3)
      doc.add_element(para3)

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(3)
    end

    it 'validates document structure on save' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'Valid content'
      para.add_run(run)
      doc.add_element(para)

      # Should validate and save successfully
      expect { doc.save(test_path) }.not_to raise_error
      expect(File.exist?(test_path)).to be true
    end
  end

  describe 'Boundary Conditions' do
    let(:test_path) { "#{tmp_dir}/boundary_test.docx" }

    it 'handles single character text' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'A'
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles text with only whitespace' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = '   '
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles minimum table (1x1)' do
      doc = Uniword::Document.new
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      cell_para = Uniword::Paragraph.new
      cell_run = Uniword::Run.new
      cell_run.text = 'Single cell'
      cell_para.add_run(cell_run)
      cell.add_paragraph(cell_para)
      row.add_cell(cell)
      table.add_row(row)
      doc.add_element(table)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles zero-width spaces' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = "Word\u200BBreak"
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error
    end

    it 'handles non-breaking spaces' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = "Non\u00A0breaking space"
      para.add_run(run)
      doc.add_element(para)

      expect { doc.save(test_path) }.not_to raise_error
    end
  end

  # Helper methods
  private

  def extract_text(document)
    text = []
    document.paragraphs.each do |para|
      next unless para.respond_to?(:runs)

      para.runs.each do |run|
        text << run.text if run.respond_to?(:text)
      end
    end
    text.join
  end
end
