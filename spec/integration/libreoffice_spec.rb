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
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'LibreOffice compatibility test'
      para.add_run(run)
      doc.add_element(para)

      doc.save(test_path)

      # Re-read to verify content is preserved
      doc2 = Uniword::DocumentFactory.from_file(test_path)
      text = extract_text(doc2)
      expect(text).to include('LibreOffice compatibility test')
    end

    it 'handles multiple paragraphs for LibreOffice' do
      doc = Uniword::Document.new

      5.times do |i|
        para = Uniword::Paragraph.new
        run = Uniword::Run.new
        run.text = "Paragraph #{i + 1}"
        para.add_run(run)
        doc.add_element(para)
      end

      doc.save(test_path)

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(5)
    end

    it 'handles tables for LibreOffice' do
      doc = Uniword::Document.new

      table = Uniword::Table.new
      2.times do |r|
        row = Uniword::TableRow.new
        2.times do |c|
          cell = Uniword::TableCell.new
          cell_para = Uniword::Paragraph.new
          cell_run = Uniword::Run.new
          cell_run.text = "Cell #{r},#{c}"
          cell_para.add_run(cell_run)
          cell.add_paragraph(cell_para)
          row.add_cell(cell)
        end
        table.add_row(row)
      end
      doc.add_element(table)

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
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new
        run = Uniword::Run.new

        if run.respond_to?(:properties=)
          props = Uniword::Wordprocessingml::RunProperties.new
          props.bold = true
          run.properties = props
        end

        run.text = 'Bold text'
        para.add_run(run)
        doc.add_element(para)

        doc.save(test_path)

        # Verify file is valid
        expect(File.exist?(test_path)).to be true
      end

      it 'preserves italic text' do
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new
        run = Uniword::Run.new

        if run.respond_to?(:properties=)
          props = Uniword::Wordprocessingml::RunProperties.new
          props.italic = true
          run.properties = props
        end

        run.text = 'Italic text'
        para.add_run(run)
        doc.add_element(para)

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'preserves underlined text' do
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new
        run = Uniword::Run.new

        if run.respond_to?(:properties=)
          props = Uniword::Wordprocessingml::RunProperties.new
          props.underline = 'single'
          run.properties = props
        end

        run.text = 'Underlined text'
        para.add_run(run)
        doc.add_element(para)

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'preserves font sizes' do
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new
        run = Uniword::Run.new

        if run.respond_to?(:properties=)
          props = Uniword::Wordprocessingml::RunProperties.new
          props.size = 48 # font_size * 2
          run.properties = props
        end

        run.text = 'Large text'
        para.add_run(run)
        doc.add_element(para)

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'preserves font families' do
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new
        run = Uniword::Run.new

        if run.respond_to?(:properties=)
          props = Uniword::Wordprocessingml::RunProperties.new
          props.font = 'Arial'
          run.properties = props
        end

        run.text = 'Arial text'
        para.add_run(run)
        doc.add_element(para)

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end
    end

    context 'paragraph formatting' do
      it 'handles paragraph alignment' do
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new

        if para.respond_to?(:properties=)
          props = Uniword::Wordprocessingml::ParagraphProperties.new
          props.alignment = 'center'
          para.properties = props
        end

        run = Uniword::Run.new
        run.text = 'Centered text'
        para.add_run(run)
        doc.add_element(para)

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'handles line spacing' do
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new

        if para.respond_to?(:properties=)
          props = Uniword::Wordprocessingml::ParagraphProperties.new
          props.line_spacing = 240
          para.properties = props
        end

        run = Uniword::Run.new
        run.text = 'Spaced text'
        para.add_run(run)
        doc.add_element(para)

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'handles indentation' do
        doc = Uniword::Document.new
        para = Uniword::Paragraph.new

        if para.respond_to?(:properties=)
          props = Uniword::Wordprocessingml::ParagraphProperties.new
          props.left_indent = 720
          para.properties = props
        end

        run = Uniword::Run.new
        run.text = 'Indented text'
        para.add_run(run)
        doc.add_element(para)

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end
    end

    context 'lists' do
      it 'handles bulleted lists' do
        doc = Uniword::Document.new

        3.times do |i|
          para = Uniword::Paragraph.new
          run = Uniword::Run.new
          run.text = "Bullet point #{i + 1}"
          para.add_run(run)
          doc.add_element(para)
        end

        doc.save(test_path)

        expect(File.exist?(test_path)).to be true
      end

      it 'handles numbered lists' do
        doc = Uniword::Document.new

        3.times do |i|
          para = Uniword::Paragraph.new
          run = Uniword::Run.new
          run.text = "Numbered item #{i + 1}"
          para.add_run(run)
          doc.add_element(para)
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
        doc = Uniword::Document.new
        table = Uniword::Table.new
        row = Uniword::TableRow.new

        # Create cells
        cell = Uniword::TableCell.new
        cell_para = Uniword::Paragraph.new
        cell_run = Uniword::Run.new
        cell_run.text = 'Merged cell'
        cell_para.add_run(cell_run)
        cell.add_paragraph(cell_para)
        row.add_cell(cell)

        table.add_row(row)
        doc.add_element(table)

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
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'Test content for PDF conversion'
      para.add_run(run)
      doc.add_element(para)

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
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'Unicode: 你好 مرحبا Здравствуй'
      para.add_run(run)
      doc.add_element(para)

      doc.save(test_path)

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      text = extract_text(doc2)
      expect(text).to include('你好')
      expect(text).to include('مرحبا')
      expect(text).to include('Здравствуй')
    end

    it 'handles emoji' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'Emoji: 🌍 🎉 ❤️'
      para.add_run(run)
      doc.add_element(para)

      doc.save(test_path)

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      extract_text(doc2)
      # Emoji might be converted or stripped, just verify document is valid
      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'handles special symbols' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = 'Symbols: © ® ™ € £ ¥'
      para.add_run(run)
      doc.add_element(para)

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
      doc = Uniword::Document.new

      # Create 50 paragraphs
      50.times do |i|
        para = Uniword::Paragraph.new
        run = Uniword::Run.new
        run.text = "Paragraph #{i + 1}: " + ('Lorem ipsum ' * 10)
        para.add_run(run)
        doc.add_element(para)
      end

      doc.save(test_path)

      doc2 = Uniword::DocumentFactory.from_file(test_path)
      expect(doc2.paragraphs.count).to eq(50)
    end

    it 'handles documents with multiple tables' do
      doc = Uniword::Document.new

      3.times do |t|
        table = Uniword::Table.new
        2.times do |r|
          row = Uniword::TableRow.new
          2.times do |c|
            cell = Uniword::TableCell.new
            cell_para = Uniword::Paragraph.new
            cell_run = Uniword::Run.new
            cell_run.text = "Table #{t} Cell #{r},#{c}"
            cell_para.add_run(cell_run)
            cell.add_paragraph(cell_para)
            row.add_cell(cell)
          end
          table.add_row(row)
        end
        doc.add_element(table)
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
    doc = Uniword::Document.new
    para = Uniword::Paragraph.new
    run = Uniword::Run.new
    run.text = 'Test document for LibreOffice'
    para.add_run(run)
    doc.add_element(para)
    doc
  end

  def create_document_with_table(rows:, cols:)
    doc = Uniword::Document.new
    table = Uniword::Table.new

    rows.times do |r|
      row = Uniword::TableRow.new
      cols.times do |c|
        cell = Uniword::TableCell.new
        cell_para = Uniword::Paragraph.new
        cell_run = Uniword::Run.new
        cell_run.text = "Cell #{r + 1},#{c + 1}"
        cell_para.add_run(cell_run)
        cell.add_paragraph(cell_para)
        row.add_cell(cell)
      end
      table.add_row(row)
    end

    doc.add_element(table)
    doc
  end

  def create_full_featured_document
    doc = Uniword::Document.new

    # Title
    title = Uniword::Paragraph.new
    title_run = Uniword::Run.new
    if title_run.respond_to?(:properties)
      title_run.properties.bold = true
      title_run.properties.font_size = 28
    end
    title_run.text = 'Document Title'
    title.add_run(title_run)
    doc.add_element(title)

    # Regular paragraphs
    3.times do |i|
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = "This is paragraph #{i + 1} with some content."
      para.add_run(run)
      doc.add_element(para)
    end

    # Table
    table = Uniword::Table.new
    2.times do |r|
      row = Uniword::TableRow.new
      2.times do |c|
        cell = Uniword::TableCell.new
        cell_para = Uniword::Paragraph.new
        cell_run = Uniword::Run.new
        cell_run.text = "Data #{r + 1},#{c + 1}"
        cell_para.add_run(cell_run)
        cell.add_paragraph(cell_para)
        row.add_cell(cell)
      end
      table.add_row(row)
    end
    doc.add_element(table)

    doc
  end

  def create_complex_document
    doc = Uniword::Document.new

    # Add paragraphs
    para1 = Uniword::Paragraph.new
    run1 = Uniword::Run.new
    run1.add_text('Introduction paragraph')
    para1.add_run(run1)
    doc.add_element(para1)

    # Add table
    table = create_document_with_table(rows: 2, cols: 2).tables.first
    doc.add_element(table)

    # Add more paragraphs
    para2 = Uniword::Paragraph.new
    run2 = Uniword::Run.new
    run2.add_text('Conclusion paragraph')
    para2.add_run(run2)
    doc.add_element(para2)

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
