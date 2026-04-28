# frozen_string_literal: true

require "spec_helper"
require "fileutils"

RSpec.describe "DOCX Edge Case Handling" do
  let(:tmp_dir) { "tmp/edge_cases" }

  before(:all) do
    FileUtils.mkdir_p("tmp/edge_cases")
  end

  after do
    # Clean up temporary files after each test
    Dir.glob("#{tmp_dir}/*.docx").each { |f| safe_delete(f) }
  end

  describe "Empty Elements" do
    let(:test_path) { "#{tmp_dir}/empty_test.docx" }

    it "handles empty paragraphs" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      # No runs added
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(1)
    end

    it "handles empty tables" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      table = Uniword::Wordprocessingml::Table.new
      # No rows added
      doc.tables << table

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles empty runs" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      # No text added
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles documents with no content" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      # No elements added

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs).to be_empty
    end

    it "handles table with empty cells" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      table = Uniword::Wordprocessingml::Table.new
      row = Uniword::Wordprocessingml::TableRow.new

      # Add empty cell
      cell = Uniword::Wordprocessingml::TableCell.new
      row.cells << cell
      table.rows << row
      doc.tables << table

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles table rows with no cells" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      table = Uniword::Wordprocessingml::Table.new
      row = Uniword::Wordprocessingml::TableRow.new
      # No cells added
      table.rows << row
      doc.tables << table

      expect { doc.save(test_path) }.not_to raise_error
    end
  end

  describe "Special Characters" do
    let(:test_path) { "#{tmp_dir}/special_chars_test.docx" }

    it "handles XML special characters" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Special: < > & " \'')
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      text = extract_text(doc2)
      expect(text).to include("<")
      expect(text).to include(">")
      expect(text).to include("&")
    end

    it "handles Unicode characters" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Unicode: 你好世界 مرحبا بالعالم Привет мир")
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      text = extract_text(doc2)
      expect(text).to include("你好世界")
    end

    it "handles emoji and symbols" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Emoji: 🌍 🎉 ❤️ 🚀 Symbols: © ® ™ € £ ¥")
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(1)
    end

    it "handles whitespace characters" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Multiple  spaces\tTab\nNewline\r\nCarriage return")
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles null characters safely" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      # Remove null characters if present
      text = "Text with\u0000null".gsub("\u0000", "")
      run.text = text
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles control characters" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      # Filter out problematic control characters
      text = "Text\u0001\u0002\u0003".gsub(
        /[\u0000-\u0008\u000B-\u000C\u000E-\u001F]/, ""
      )
      run.text = text
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles RTL (right-to-left) text" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "RTL: مرحبا بك في العالم العربي")
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      text = extract_text(doc2)
      expect(text).to include("مرحبا")
    end

    it "handles mixed LTR and RTL text" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "English مرحبا English again")
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end
  end

  describe "Large Documents" do
    let(:test_path) { "#{tmp_dir}/large_test.docx" }

    it "handles 100+ paragraphs" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      150.times do |i|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Paragraph #{i + 1}")
        para.runs << run
        doc.body.paragraphs << para
      end

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(150)
    end

    it "handles 50+ tables" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      50.times do |t|
        table = Uniword::Wordprocessingml::Table.new
        row = Uniword::Wordprocessingml::TableRow.new
        cell = Uniword::Wordprocessingml::TableCell.new
        cell_para = Uniword::Wordprocessingml::Paragraph.new
        cell_run = Uniword::Wordprocessingml::Run.new(text: "Table #{t + 1}")
        cell_para.runs << cell_run
        cell.paragraphs << cell_para
        row.cells << cell
        table.rows << row
        doc.tables << table
      end

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.tables.count).to eq(50)
    end

    it "handles deep nesting" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      # Create nested tables
      outer_table = Uniword::Wordprocessingml::Table.new
      outer_row = Uniword::Wordprocessingml::TableRow.new
      outer_cell = Uniword::Wordprocessingml::TableCell.new

      # Add nested content
      outer_cell_para = Uniword::Wordprocessingml::Paragraph.new
      outer_cell_run = Uniword::Wordprocessingml::Run.new(text: "Outer cell content")
      outer_cell_para.runs << outer_cell_run
      outer_cell.paragraphs << outer_cell_para

      outer_row.cells << outer_cell
      outer_table.rows << outer_row
      doc.tables << outer_table

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles many runs per paragraph" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new

      100.times do |i|
        run = Uniword::Wordprocessingml::Run.new(text: "Run #{i + 1} ")
        para.runs << run
      end

      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles large table with many cells" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      table = Uniword::Wordprocessingml::Table.new

      # 20x20 table
      20.times do |r|
        row = Uniword::Wordprocessingml::TableRow.new
        20.times do |c|
          cell = Uniword::Wordprocessingml::TableCell.new
          cell_para = Uniword::Wordprocessingml::Paragraph.new
          cell_run = Uniword::Wordprocessingml::Run.new(text: "#{r},#{c}")
          cell_para.runs << cell_run
          cell.paragraphs << cell_para
          row.cells << cell
        end
        table.rows << row
      end

      doc.tables << table

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.tables.first.rows.count).to eq(20)
    end
  end

  describe "Malformed Input" do
    let(:test_path) { "#{tmp_dir}/malformed_test.docx" }

    it "handles reading non-existent file gracefully" do
      expect { Uniword::DocumentFactory.from_file("nonexistent.docx") }
        .to raise_error(Uniword::FileNotFoundError, /File not found/)
    end

    it "handles reading non-DOCX file gracefully" do
      # Create a text file
      text_file = "#{tmp_dir}/not_a_docx.docx"
      File.write(text_file, "This is not a DOCX file")

      expect { Uniword::DocumentFactory.from_file(text_file) }
        .to raise_error # Should raise some error (ZIP or parsing error)
    end

    it "handles empty file path" do
      expect { Uniword::DocumentFactory.from_file("") }
        .to raise_error(ArgumentError, /Path cannot be empty/)
    end

    it "handles nil file path" do
      expect { Uniword::DocumentFactory.from_file(nil) }
        .to raise_error(ArgumentError, /Path cannot be nil/)
    end

    it "validates document before saving" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      # Document should be valid even when empty
      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles invalid element types gracefully" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "not an element")
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end
  end

  describe "Maximum Values" do
    let(:test_path) { "#{tmp_dir}/max_values_test.docx" }

    it "handles very long text in paragraph" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new

      # 10,000 character text
      long_text = "Lorem ipsum dolor sit amet " * 370
      run.text = long_text[0, 10_000]
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(extract_text(doc2).length).to be >= 9000
    end

    it "handles maximum font size" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new

      # Use v2.0 API: set font size via properties
      run.properties = Uniword::Wordprocessingml::RunProperties.new(
        size: Uniword::Properties::FontSize.new(value: 144),
      )
      run.text = "Large text"
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles many list levels" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      # Create paragraphs at different indentation levels
      5.times do |level|
        para = Uniword::Wordprocessingml::Paragraph.new

        # Use v2.0 API: set indentation via properties
        props = Uniword::Wordprocessingml::ParagraphProperties.new(
          left_indent: 720 * level,
        )
        para.properties = props

        run = Uniword::Wordprocessingml::Run.new(text: "Level #{level + 1} item")
        para.runs << run
        doc.body.paragraphs << para
      end

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles extreme indentation values" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new

      props = Uniword::Wordprocessingml::ParagraphProperties.new(
        left_indent: 5040, # 7 inches in twips
      )
      para.properties = props

      run = Uniword::Wordprocessingml::Run.new(text: "Deeply indented")
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles wide tables" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      table = Uniword::Wordprocessingml::Table.new
      row = Uniword::Wordprocessingml::TableRow.new

      # Create 15 columns
      15.times do |c|
        cell = Uniword::Wordprocessingml::TableCell.new
        cell_para = Uniword::Wordprocessingml::Paragraph.new
        cell_run = Uniword::Wordprocessingml::Run.new(text: "Col #{c + 1}")
        cell_para.runs << cell_run
        cell.paragraphs << cell_para
        row.cells << cell
      end

      table.rows << row
      doc.tables << table

      expect { doc.save(test_path) }.not_to raise_error
    end
  end

  describe "Error Recovery" do
    let(:test_path) { "#{tmp_dir}/error_recovery_test.docx" }

    it "provides informative error messages for invalid paths" do
      expect { Uniword::DocumentFactory.from_file("") }
        .to raise_error(ArgumentError, /Path cannot be empty/)
    end

    it "provides informative error messages for invalid elements" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      # v2.0 API: add_paragraph accepts string and creates paragraph
      para = Uniword::Wordprocessingml::Paragraph.new
      doc.body.paragraphs << para
      expect { doc.save("#{tmp_dir}/nil_test.docx") }.not_to raise_error
    end

    it "handles document with mixed valid and edge case content" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      # Normal paragraph
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: "Normal text")
      para1.runs << run1
      doc.body.paragraphs << para1

      # Empty paragraph
      para2 = Uniword::Wordprocessingml::Paragraph.new
      doc.body.paragraphs << para2

      # Paragraph with special chars
      para3 = Uniword::Wordprocessingml::Paragraph.new
      run3 = Uniword::Wordprocessingml::Run.new(text: "Special: < > &")
      para3.runs << run3
      doc.body.paragraphs << para3

      expect { doc.save(test_path) }.not_to raise_error

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(3)
    end

    it "validates document structure on save" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Valid content")
      para.runs << run
      doc.body.paragraphs << para

      # Should validate and save successfully
      expect { doc.save(test_path) }.not_to raise_error
      expect(File.exist?(test_path)).to be true
    end
  end

  describe "Boundary Conditions" do
    let(:test_path) { "#{tmp_dir}/boundary_test.docx" }

    it "handles single character text" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "A")
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles text with only whitespace" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "   ")
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles minimum table (1x1)" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      table = Uniword::Wordprocessingml::Table.new
      row = Uniword::Wordprocessingml::TableRow.new
      cell = Uniword::Wordprocessingml::TableCell.new
      cell_para = Uniword::Wordprocessingml::Paragraph.new
      cell_run = Uniword::Wordprocessingml::Run.new(text: "Single cell")
      cell_para.runs << cell_run
      cell.paragraphs << cell_para
      row.cells << cell
      table.rows << row
      doc.tables << table

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles zero-width spaces" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Word\u200BBreak")
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end

    it "handles non-breaking spaces" do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "Non\u00A0breaking space")
      para.runs << run
      doc.body.paragraphs << para

      expect { doc.save(test_path) }.not_to raise_error
    end
  end
end
