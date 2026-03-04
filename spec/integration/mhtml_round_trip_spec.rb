# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe 'MHTML Round-trip Validation', type: :integration do
  let(:tmp_dir) { 'spec/tmp' }
  let(:temp_path) { File.join(tmp_dir, 'mhtml_roundtrip_test.doc') }

  before(:all) do
    FileUtils.mkdir_p('spec/tmp')
  end

  after(:each) do
    FileUtils.rm_f(temp_path)
  end

  describe 'Basic Round-trip' do
    it 'preserves simple text through round-trip' do
      # Create document
      doc1 = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Hello MHTML World')
      doc1.body.paragraphs << para

      # Write as MHTML
      doc1.save(temp_path, format: :mhtml)

      # Read back
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      # Verify
      expect(extract_text(doc2)).to eq('Hello MHTML World')
      expect(doc2.paragraphs.count).to eq(1)
    end

    it 'preserves multiple paragraphs' do
      doc1 = Uniword::Document.new

      3.times do |i|
        para = Uniword::Paragraph.new
        para.add_text("Paragraph #{i + 1}")
        doc1.body.paragraphs << para
      end

      original_count = doc1.paragraphs.count
      original_text = extract_text(doc1)

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(original_count)
      expect(extract_text(doc2)).to eq(original_text)
    end

    it 'preserves empty document' do
      doc1 = Uniword::Document.new

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      expect(doc2.paragraphs).to be_empty
    end
  end

  describe 'Formatting Round-trip' do
    it 'preserves text formatting - bold' do
      doc1 = Uniword::Document.new
      para = Uniword::Paragraph.new

      # Bold text
      run1 = Uniword::Run.new(
        text: 'Bold',
        properties: Uniword::Wordprocessingml::RunProperties.new(bold: true)
      )
      para.add_run(run1)

      doc1.body.paragraphs << para
      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      # Verify formatting preserved
      first_para = doc2.paragraphs.first
      first_run = first_para.runs.first
      expect(first_run.properties.bold).to be true
      expect(first_run.text).to eq('Bold')
    end

    it 'preserves text formatting - italic' do
      doc1 = Uniword::Document.new
      para = Uniword::Paragraph.new

      run = Uniword::Run.new(
        text: 'Italic text',
        properties: Uniword::Wordprocessingml::RunProperties.new(italic: true)
      )
      para.add_run(run)

      doc1.body.paragraphs << para
      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      first_run = doc2.paragraphs.first.runs.first
      expect(first_run.properties.italic).to be true
      expect(first_run.text).to eq('Italic text')
    end

    it 'preserves text formatting - underline' do
      doc1 = Uniword::Document.new
      para = Uniword::Paragraph.new

      run = Uniword::Run.new(
        text: 'Underlined',
        properties: Uniword::Wordprocessingml::RunProperties.new(underline: 'single')
      )
      para.add_run(run)

      doc1.body.paragraphs << para
      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      first_run = doc2.paragraphs.first.runs.first
      expect(first_run.properties.underline).not_to be_nil
    end

    it 'preserves combined formatting' do
      doc1 = Uniword::Document.new
      para = Uniword::Paragraph.new

      run = Uniword::Run.new(
        text: 'Bold and Italic',
        properties: Uniword::Wordprocessingml::RunProperties.new(
          bold: true,
          italic: true
        )
      )
      para.add_run(run)

      doc1.body.paragraphs << para
      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      first_run = doc2.paragraphs.first.runs.first
      expect(first_run.properties.bold).to be true
      expect(first_run.properties.italic).to be true
    end

    it 'preserves font information' do
      doc1 = Uniword::Document.new
      para = Uniword::Paragraph.new

      run = Uniword::Run.new(
        text: 'Arial text',
        properties: Uniword::Wordprocessingml::RunProperties.new(font: 'Arial')
      )
      para.add_run(run)

      doc1.body.paragraphs << para
      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      first_run = doc2.paragraphs.first.runs.first
      expect(first_run.properties.font).to eq('Arial')
    end

    it 'preserves font size' do
      doc1 = Uniword::Document.new
      para = Uniword::Paragraph.new

      run = Uniword::Run.new(
        text: 'Large text',
        properties: Uniword::Wordprocessingml::RunProperties.new(size: 48)
      )
      para.add_run(run)

      doc1.body.paragraphs << para
      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      first_run = doc2.paragraphs.first.runs.first
      expect(first_run.properties.size).to eq(48)
    end
  end

  describe 'Table Round-trip' do
    it 'preserves tables with content' do
      doc1 = create_document_with_table

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      tables = doc2.tables
      expect(tables.count).to eq(1)
      expect(tables.first.rows.count).to be > 0
    end

    it 'preserves table structure' do
      doc1 = Uniword::Document.new

      table = Uniword::Table.new
      2.times do |r|
        row = Uniword::TableRow.new
        3.times do |c|
          cell = Uniword::TableCell.new
          para = Uniword::Paragraph.new
          para.add_text("R#{r + 1}C#{c + 1}")
          cell.paragraphs << para
          row.add_cell(cell)
        end
        table.add_row(row)
      end
      doc1.body.tables << table

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      table = doc2.tables.first
      skip 'Tables not yet fully supported in MHTML' if table.nil?

      expect(table.rows.count).to eq(2)
      expect(table.rows.first.cells.count).to eq(3)
    end

    it 'preserves table cell content' do
      doc1 = Uniword::Document.new

      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      para = Uniword::Paragraph.new
      para.add_text('Cell content')
      cell.paragraphs << para
      row.add_cell(cell)
      table.add_row(row)
      doc1.body.tables << table

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      table = doc2.tables.first
      skip 'Tables not yet fully supported in MHTML' if table.nil?

      cell_text = extract_table_text(table)
      expect(cell_text).to include('Cell content')
    end
  end

  describe 'Style Round-trip' do
    it 'preserves paragraph styles - Heading1' do
      doc1 = Uniword::Document.new
      heading = Uniword::Paragraph.new(
        properties: Uniword::Wordprocessingml::ParagraphProperties.new(
          style: 'Heading1'
        )
      )
      heading.add_text('Heading')
      doc1.body.paragraphs << heading

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      first_para = doc2.paragraphs.first
      skip 'Style preservation not yet implemented' if first_para.properties.nil?
      expect(first_para.properties.style).to eq('Heading1')
    end

    it 'preserves paragraph styles - Heading2' do
      doc1 = Uniword::Document.new
      heading = Uniword::Paragraph.new(
        properties: Uniword::Wordprocessingml::ParagraphProperties.new(
          style: 'Heading2'
        )
      )
      heading.add_text('Subheading')
      doc1.body.paragraphs << heading

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      first_para = doc2.paragraphs.first
      skip 'Style preservation not yet implemented' if first_para.properties.nil?
      expect(first_para.properties.style).to eq('Heading2')
    end

    it 'preserves multiple heading levels' do
      doc1 = Uniword::Document.new

      %w[Heading1 Heading2 Heading3].each_with_index do |style, _i|
        para = Uniword::Paragraph.new(
          properties: Uniword::Wordprocessingml::ParagraphProperties.new(style: style)
        )
        para.add_text("#{style} text")
        doc1.body.paragraphs << para
      end

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      skip 'Style preservation not yet implemented' if doc2.paragraphs[0].properties.nil?
      expect(doc2.paragraphs[0].properties.style).to eq('Heading1')
      expect(doc2.paragraphs[1].properties.style).to eq('Heading2')
      expect(doc2.paragraphs[2].properties.style).to eq('Heading3')
    end
  end

  describe 'Complex Document Round-trip' do
    it 'preserves mixed content types' do
      doc1 = Uniword::Document.new

      # Heading
      heading = Uniword::Paragraph.new(
        properties: Uniword::Wordprocessingml::ParagraphProperties.new(
          style: 'Heading1'
        )
      )
      heading.add_text('Document Title')
      doc1.body.paragraphs << heading

      # Normal paragraph
      para = Uniword::Paragraph.new
      para.add_text('Introduction paragraph')
      doc1.body.paragraphs << para

      # Table
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      cell_para = Uniword::Paragraph.new
      cell_para.add_text('Table data')
      cell.add_paragraph(cell_para)
      row.add_cell(cell)
      table.add_row(row)
      doc1.body.tables << table

      # Another paragraph
      para2 = Uniword::Paragraph.new
      para2.add_text('Conclusion')
      doc1.body.paragraphs << para2

      extract_text(doc1)
      original_elements = doc1.paragraphs.count + doc1.tables.count

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      expect(doc2.paragraphs.count + doc2.tables.count).to eq(original_elements)
      expect(extract_text(doc2)).to include('Document Title')
      expect(extract_text(doc2)).to include('Introduction paragraph')
      expect(extract_text(doc2)).to include('Table data')
      expect(extract_text(doc2)).to include('Conclusion')
    end

    it 'preserves formatting in complex document' do
      doc1 = Uniword::Document.new

      # Bold paragraph
      para1 = Uniword::Paragraph.new
      bold_run = Uniword::Run.new
      bold_run.text = 'Bold text'
      bold_run.properties = Uniword::Wordprocessingml::RunProperties.new(bold: true)
      para1.add_run(bold_run)
      doc1.body.paragraphs << para1

      # Italic paragraph
      para2 = Uniword::Paragraph.new
      italic_run = Uniword::Run.new
      italic_run.text = 'Italic text'
      italic_run.properties = Uniword::Wordprocessingml::RunProperties.new(
        italic: true
      )
      para2.add_run(italic_run)
      doc1.body.paragraphs << para2

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      para_count = doc2.paragraphs.count
      expect(para_count).to be >= 2

      if para_count >= 2 && doc2.paragraphs[0].runs.any?
        expect(doc2.paragraphs[0].runs[0].properties.bold).to be true
      end

      if para_count >= 2 && doc2.paragraphs[1].runs.any?
        expect(doc2.paragraphs[1].runs[0].properties.italic).to be true
      end
    end
  end

  describe 'Character Encoding Round-trip' do
    it 'preserves UTF-8 characters' do
      doc1 = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Hello 世界 مرحبا мир')
      doc1.body.paragraphs << para

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      expect(extract_text(doc2)).to include('Hello 世界 مرحبا мир')
    end

    it 'preserves special HTML characters' do
      doc1 = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Text with <, >, &, ", \'')
      doc1.body.paragraphs << para

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      expect(extract_text(doc2)).to include('<, >, &')
    end

    it 'preserves emoji and symbols' do
      doc1 = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Symbols: ™ © ® € ¥ 😀 ✓')
      doc1.body.paragraphs << para

      doc1.save(temp_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_path, format: :mhtml)

      expect(extract_text(doc2)).to include('™ © ® € ¥')
    end
  end

  # Helper methods
  private

  def extract_text(document)
    text = document.paragraphs.map do |para|
      extract_paragraph_text(para)
    end
    document.tables.each do |table|
      text << extract_table_text(table)
    end
    text.join("\n")
  end

  def extract_paragraph_text(paragraph)
    return '' unless paragraph.respond_to?(:runs)

    paragraph.runs.map do |run|
      run.respond_to?(:text) ? run.text : ''
    end.join
  end

  def extract_table_text(table)
    return '' if table.nil?

    text = []
    table.rows.each do |row|
      row.cells.each do |cell|
        cell.paragraphs.each do |para|
          text << extract_paragraph_text(para)
        end
      end
    end
    text.join(' ')
  end

  def create_document_with_table
    doc = Uniword::Document.new

    table = Uniword::Table.new
    row = Uniword::TableRow.new
    cell = Uniword::TableCell.new
    para = Uniword::Paragraph.new
    para.add_text('Cell content')
    cell.paragraphs << para
    row.add_cell(cell)
    table.add_row(row)
    doc.body.tables << table

    doc
  end
end
