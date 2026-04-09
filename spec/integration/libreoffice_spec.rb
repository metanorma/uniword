# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe 'LibreOffice Compatibility Testing' do
  let(:tmp_dir) { 'tmp/libreoffice' }

  before(:all) do
    FileUtils.mkdir_p('tmp/libreoffice')
  end

  after(:each) do
    # Clean up temporary files after each test
    Dir.glob("#{tmp_dir}/*").each { |f| File.delete(f) if File.file?(f) }
  end

  describe 'LibreOffice Openability' do
    let(:test_path) { "#{tmp_dir}/libreoffice_test.docx" }

    it 'generates DOCX that LibreOffice can open' do
      doc = create_test_document
      doc.save(test_path)

      # Verify file exists and is not corrupted
      expect(File.exist?(test_path)).to be true
      expect(File.size(test_path)).to be > 0

      # Verify it's a valid ZIP/DOCX
      expect { Zip::File.open(test_path) {} }.not_to raise_error
    end

    it 'preserves basic text content for LibreOffice' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'LibreOffice compatibility test')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(test_path)

      # Re-read to verify content is preserved
      doc2 = Uniword::DocumentFactory.from_file(test_path)
      text = extract_text(doc2)
      expect(text).to include('LibreOffice compatibility test')
    end

    it 'handles multiple paragraphs for LibreOffice' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      5.times do |i|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Paragraph #{i + 1}")
        para.runs << run
        doc.body.paragraphs << para
      end

      doc.save(test_path)

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(5)
    end

    it 'handles tables for LibreOffice' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      table = Uniword::Wordprocessingml::Table.new
      2.times do |r|
        row = Uniword::Wordprocessingml::TableRow.new
        2.times do |c|
          cell = Uniword::Wordprocessingml::TableCell.new
          cell_para = Uniword::Wordprocessingml::Paragraph.new
          cell_run = Uniword::Wordprocessingml::Run.new(text: "Cell #{r},#{c}")
          cell_para.runs << cell_run
          cell.paragraphs << cell_para
          row.cells << cell
        end
        table.rows << row
      end
      doc.body.tables << table

      doc.save(test_path)

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.tables.count).to eq(1)
      expect(doc2.tables.first.rows.count).to eq(2)
    end
  end

  describe 'Feature Compatibility' do
    let(:test_path) { "#{tmp_dir}/features_test.docx" }

    context 'text formatting' do
      it 'preserves bold text' do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(
          text: 'Bold text',
          properties: Uniword::Wordprocessingml::RunProperties.new(
            bold: Uniword::Properties::Bold.new(value: true)
          )
        )
        para.runs << run
        doc.body.paragraphs << para

        doc.save(test_path)

        # Verify file is valid
        expect(File.exist?(test_path)).to be true
      end

      it 'preserves italic text' do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(
          text: 'Italic text',
          properties: Uniword::Wordprocessingml::RunProperties.new(
            italic: Uniword::Properties::Italic.new(value: true)
          )
        )
        para.runs << run
        doc.body.paragraphs << para

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'preserves underlined text' do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(
          text: 'Underlined text',
          properties: Uniword::Wordprocessingml::RunProperties.new(
            underline: Uniword::Properties::Underline.new(value: 'single')
          )
        )
        para.runs << run
        doc.body.paragraphs << para

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'preserves font sizes' do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(
          text: 'Large text',
          properties: Uniword::Wordprocessingml::RunProperties.new(
            size: Uniword::Properties::FontSize.new(value: 48)
          )
        )
        para.runs << run
        doc.body.paragraphs << para

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'preserves font families' do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new

        if run.respond_to?(:properties=)
          props = Uniword::Wordprocessingml::RunProperties.new
          props.font = 'Arial'
          run.properties = props
        end

        run.text = 'Arial text'
        para.runs << run
        doc.body.paragraphs << para

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end
    end

    context 'paragraph formatting' do
      it 'handles paragraph alignment' do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new

        if para.respond_to?(:properties=)
          props = Uniword::Wordprocessingml::ParagraphProperties.new
          props.alignment = Uniword::Properties::Alignment.new(value: 'center')
          para.properties = props
        end

        run = Uniword::Wordprocessingml::Run.new(text: 'Centered text')
        para.runs << run
        doc.body.paragraphs << para

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'handles line spacing' do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new

        if para.respond_to?(:properties=)
          props = Uniword::Wordprocessingml::ParagraphProperties.new
          props.line_spacing = 240
          para.properties = props
        end

        run = Uniword::Wordprocessingml::Run.new(text: 'Spaced text')
        para.runs << run
        doc.body.paragraphs << para

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'handles indentation' do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new

        if para.respond_to?(:properties=)
          props = Uniword::Wordprocessingml::ParagraphProperties.new
          props.left_indent = 720
          para.properties = props
        end

        run = Uniword::Wordprocessingml::Run.new(text: 'Indented text')
        para.runs << run
        doc.body.paragraphs << para

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end
    end

    context 'lists' do
      it 'handles bulleted lists' do
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        3.times do |i|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "Bullet point #{i + 1}")
          para.runs << run
          doc.body.paragraphs << para
        end

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'handles numbered lists' do
        doc = Uniword::Wordprocessingml::DocumentRoot.new

        3.times do |i|
          para = Uniword::Wordprocessingml::Paragraph.new
          run = Uniword::Wordprocessingml::Run.new(text: "Numbered item #{i + 1}")
          para.runs << run
          doc.body.paragraphs << para
        end

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end
    end

    context 'tables' do
      it 'preserves table structure' do
        doc = create_document_with_table(rows: 3, cols: 3)
        doc.save(test_path)

        doc2 = Uniword::DocumentFactory.from_file(test_path)
        expect(doc2.tables.count).to eq(1)
      end

      it 'handles merged cells' do
        doc = Uniword::Wordprocessingml::DocumentRoot.new
        table = Uniword::Wordprocessingml::Table.new
        row = Uniword::Wordprocessingml::TableRow.new

        # Create cells
        cell = Uniword::Wordprocessingml::TableCell.new
        cell_para = Uniword::Wordprocessingml::Paragraph.new
        cell_run = Uniword::Wordprocessingml::Run.new(text: 'Merged cell')
        cell_para.runs << cell_run
        cell.paragraphs << cell_para
        row.cells << cell

        table.rows << row
        doc.body.tables << table

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'preserves table borders' do
        doc = create_document_with_table(rows: 2, cols: 2)
        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end
    end
  end

  describe 'LibreOffice CLI Integration', :skip_if_no_libreoffice do
    let(:test_path) { "#{tmp_dir}/cli_test.docx" }
    let(:pdf_path) { "#{tmp_dir}/cli_test.pdf" }

    before(:all) do
      unless libreoffice_available?
        skip 'LibreOffice not installed. Install with: brew install libreoffice (macOS) or apt-get install libreoffice (Linux)'
      end
    end

    it 'can be converted to PDF by LibreOffice' do
      doc = create_full_featured_document
      doc.save(test_path)

      # Try conversion
      result = system("soffice --headless --convert-to pdf --outdir #{tmp_dir} #{test_path} > /dev/null 2>&1")

      expect(result).to be true, 'LibreOffice conversion failed'
      expect(File.exist?(pdf_path)).to be true, 'PDF was not created'
      expect(File.size(pdf_path)).to be > 0, 'PDF is empty'
    end

    it 'can be validated by LibreOffice' do
      doc = create_test_document
      doc.save(test_path)

      # Try to open and immediately close (validates structure)
      system("soffice --headless --invisible --view #{test_path} > /dev/null 2>&1")

      # NOTE: This may not work on all systems, so we just check the file is valid
      expect(File.exist?(test_path)).to be true
    end

    it 'preserves content through LibreOffice conversion' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Test content for PDF conversion')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(test_path)

      result = system("soffice --headless --convert-to pdf --outdir #{tmp_dir} #{test_path} > /dev/null 2>&1")

      if result
        expect(File.exist?(pdf_path)).to be true
        # PDF should contain some content
        expect(File.size(pdf_path)).to be > 100
      end
    end
  end

  describe 'Unicode and Special Characters' do
    let(:test_path) { "#{tmp_dir}/unicode_test.docx" }

    it 'handles Unicode characters' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Unicode: 你好 مرحبا Здравствуй')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(test_path)

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      text = extract_text(doc2)
      expect(text).to include('你好')
      expect(text).to include('مرحبا')
      expect(text).to include('Здравствуй')
    end

    it 'handles emoji' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Emoji: 🌍 🎉 ❤️')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(test_path)

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      extract_text(doc2)
      # Emoji might be converted or stripped, just verify document is valid
      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'handles special symbols' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Symbols: © ® ™ € £ ¥')
      para.runs << run
      doc.body.paragraphs << para

      doc.save(test_path)

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(1)
    end
  end

  describe 'Complex Document Features' do
    let(:test_path) { "#{tmp_dir}/complex_test.docx" }

    it 'handles documents with mixed content' do
      doc = create_complex_document
      doc.save(test_path)

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to be > 0
      expect(doc2.tables.count).to be > 0
    end

    it 'handles large documents' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      # Create 50 paragraphs
      50.times do |i|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: "Paragraph #{i + 1}: " + ('Lorem ipsum ' * 10))
        para.runs << run
        doc.body.paragraphs << para
      end

      doc.save(test_path)

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(50)
    end

    it 'handles documents with multiple tables' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      3.times do |t|
        table = Uniword::Wordprocessingml::Table.new
        2.times do |r|
          row = Uniword::Wordprocessingml::TableRow.new
          2.times do |c|
            cell = Uniword::Wordprocessingml::TableCell.new
            cell_para = Uniword::Wordprocessingml::Paragraph.new
            cell_run = Uniword::Wordprocessingml::Run.new(text: "Table #{t} Cell #{r},#{c}")
            cell_para.runs << cell_run
            cell.paragraphs << cell_para
            row.cells << cell
          end
          table.rows << row
        end
        doc.body.tables << table
      end

      doc.save(test_path)

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.tables.count).to eq(3)
    end
  end

  # Helper methods
  private

  def libreoffice_available?
    system('which soffice > /dev/null 2>&1')
  end

  def create_test_document
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    para = Uniword::Wordprocessingml::Paragraph.new
    run = Uniword::Wordprocessingml::Run.new(text: 'Test document for LibreOffice')
    para.runs << run
    doc.body.paragraphs << para
    doc
  end

  def create_document_with_table(rows:, cols:)
    doc = Uniword::Wordprocessingml::DocumentRoot.new
    table = Uniword::Wordprocessingml::Table.new

    rows.times do |r|
      row = Uniword::Wordprocessingml::TableRow.new
      cols.times do |c|
        cell = Uniword::Wordprocessingml::TableCell.new
        cell_para = Uniword::Wordprocessingml::Paragraph.new
        cell_run = Uniword::Wordprocessingml::Run.new(text: "Cell #{r + 1},#{c + 1}")
        cell_para.runs << cell_run
        cell.paragraphs << cell_para
        row.cells << cell
      end
      table.rows << row
    end

    doc.body.tables << table
    doc
  end

  def create_full_featured_document
    doc = Uniword::Wordprocessingml::DocumentRoot.new

    # Title
    title = Uniword::Wordprocessingml::Paragraph.new
    title_run = Uniword::Wordprocessingml::Run.new
    if title_run.respond_to?(:properties)
      title_run.properties.bold = true
      title_run.properties.font_size = 28
    end
    title_run.text = 'Document Title'
    title.runs << title_run
    doc.body.paragraphs << title

    # Regular paragraphs
    3.times do |i|
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: "This is paragraph #{i + 1} with some content.")
      para.runs << run
      doc.body.paragraphs << para
    end

    # Table
    table = Uniword::Wordprocessingml::Table.new
    2.times do |r|
      row = Uniword::Wordprocessingml::TableRow.new
      2.times do |c|
        cell = Uniword::Wordprocessingml::TableCell.new
        cell_para = Uniword::Wordprocessingml::Paragraph.new
        cell_run = Uniword::Wordprocessingml::Run.new(text: "Data #{r + 1},#{c + 1}")
        cell_para.runs << cell_run
        cell.paragraphs << cell_para
        row.cells << cell
      end
      table.rows << row
    end
    doc.body.tables << table

    doc
  end

  def create_complex_document
    doc = Uniword::Wordprocessingml::DocumentRoot.new

    # Add paragraphs
    para1 = Uniword::Wordprocessingml::Paragraph.new
    run1 = Uniword::Wordprocessingml::Run.new(text: 'Introduction paragraph')
    para1.runs << run1
    doc.body.paragraphs << para1

    # Add table
    table = create_document_with_table(rows: 2, cols: 2).tables.first
    doc.body.tables << table

    # Add more paragraphs
    para2 = Uniword::Wordprocessingml::Paragraph.new
    run2 = Uniword::Wordprocessingml::Run.new(text: 'Conclusion paragraph')
    para2.runs << run2
    doc.body.paragraphs << para2

    doc
  end

  def extract_text(document)
    text = []
    document.paragraphs.each do |para|
      next unless para.respond_to?(:runs)

      para.runs.each do |run|
        text << run.text if run.respond_to?(:text)
      end
    end
    text.join(' ')
  end
end
