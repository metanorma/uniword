# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe 'Format Conversion', type: :integration do
  let(:tmp_dir) { 'spec/tmp' }
  let(:fixtures_dir) { '/Users/mulgogi/src/external/docx/spec/fixtures' }

  before(:all) do
    FileUtils.mkdir_p('spec/tmp')
  end

  after(:each) do
    Dir.glob("#{tmp_dir}/*.{docx,doc,mhtml}").each { |f| File.delete(f) }
  end

  describe 'DOCX to MHTML Conversion' do
    let(:docx_path) { "#{fixtures_dir}/basic.docx" }
    let(:mhtml_path) { "#{tmp_dir}/converted.doc" }

    it 'converts DOCX to MHTML' do
      # Read DOCX
      doc = Uniword::DocumentFactory.from_file(docx_path)
      original_text = doc.text

      # Save as MHTML
      doc.save(mhtml_path, format: :mhtml)

      # Verify file was created
      expect(File.exist?(mhtml_path)).to be true

      # Read MHTML back
      doc2 = Uniword::DocumentFactory.from_file(mhtml_path, format: :mhtml)

      # Verify text preserved
      expect(doc2.text).to eq(original_text)
    end

    it 'preserves paragraph count in conversion' do
      doc = Uniword::DocumentFactory.from_file(docx_path)
      original_count = doc.paragraphs.count

      doc.save(mhtml_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(mhtml_path, format: :mhtml)

      expect(doc2.paragraphs.count).to eq(original_count)
    end

    it 'preserves text content across conversion' do
      doc = Uniword::DocumentFactory.from_file(docx_path)
      original_paragraphs = doc.paragraphs.map { |p| extract_paragraph_text(p) }

      doc.save(mhtml_path, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(mhtml_path, format: :mhtml)

      converted_paragraphs = doc2.paragraphs.map { |p| extract_paragraph_text(p) }
      expect(converted_paragraphs).to eq(original_paragraphs)
    end
  end

  describe 'MHTML to DOCX Conversion' do
    let(:docx_path) { "#{tmp_dir}/converted.docx" }
    let(:mhtml_path) { "#{tmp_dir}/test.doc" }

    it 'converts MHTML to DOCX' do
      # Create MHTML document
      doc = Uniword::Document.new
      doc.add_paragraph('Test conversion')
      doc.save(mhtml_path, format: :mhtml)

      # Read MHTML
      doc1 = Uniword::DocumentFactory.from_file(mhtml_path, format: :mhtml)

      # Save as DOCX
      doc1.save(docx_path, format: :docx)

      # Read DOCX back
      doc2 = Uniword::DocumentFactory.from_file(docx_path, format: :docx)

      # Verify
      expect(doc2.text).to include('Test conversion')
    end

    it 'preserves paragraph structure in conversion' do
      # Create MHTML with multiple paragraphs
      doc = Uniword::Document.new
      3.times do |i|
        doc.add_paragraph("Paragraph #{i + 1}")
      end
      doc.save(mhtml_path, format: :mhtml)

      # Convert MHTML → DOCX
      doc1 = Uniword::DocumentFactory.from_file(mhtml_path, format: :mhtml)
      original_count = doc1.paragraphs.count

      doc1.save(docx_path, format: :docx)
      doc2 = Uniword::DocumentFactory.from_file(docx_path, format: :docx)

      expect(doc2.paragraphs.count).to eq(original_count)
    end
  end

  describe 'Round-trip Conversions' do
    let(:temp_docx1) { "#{tmp_dir}/test.docx" }
    let(:temp_mhtml) { "#{tmp_dir}/test.doc" }
    let(:temp_docx2) { "#{tmp_dir}/test2.docx" }

    it 'preserves formatting across DOCX → MHTML → DOCX' do
      # Create document with formatting
      doc = create_formatted_document

      # DOCX → MHTML → DOCX
      doc.save(temp_docx1)
      doc1 = Uniword::DocumentFactory.from_file(temp_docx1)
      doc1.save(temp_mhtml, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_mhtml, format: :mhtml)
      doc2.save(temp_docx2)
      doc3 = Uniword::DocumentFactory.from_file(temp_docx2)

      # Verify text preserved through conversions
      expect(doc3.text).to eq(doc.text)
    end

    it 'preserves bold formatting across conversions' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new

      run = Uniword::Run.new
      run.text = 'Bold text'
      run.properties = Uniword::Wordprocessingml::RunProperties.new(bold: true)
      para.add_run(run)
      doc.body.paragraphs << para

      # DOCX → MHTML → DOCX
      doc.save(temp_docx1)
      doc1 = Uniword::DocumentFactory.from_file(temp_docx1)
      doc1.save(temp_mhtml, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_mhtml, format: :mhtml)
      doc2.save(temp_docx2)
      doc3 = Uniword::DocumentFactory.from_file(temp_docx2)

      # Verify bold preserved
      first_run = doc3.paragraphs.first.runs.first
      expect(first_run.properties.bold).to be true
    end

    it 'preserves italic formatting across conversions' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new

      run = Uniword::Run.new
      run.text = 'Italic text'
      run.properties = Uniword::Wordprocessingml::RunProperties.new(italic: true)
      para.add_run(run)
      doc.body.paragraphs << para

      # DOCX → MHTML → DOCX
      doc.save(temp_docx1)
      doc1 = Uniword::DocumentFactory.from_file(temp_docx1)
      doc1.save(temp_mhtml, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_mhtml, format: :mhtml)
      doc2.save(temp_docx2)
      doc3 = Uniword::DocumentFactory.from_file(temp_docx2)

      # Verify italic preserved
      first_run = doc3.paragraphs.first.runs.first
      expect(first_run.properties.italic).to be true
    end

    it 'preserves tables across conversions' do
      doc = create_document_with_table

      # DOCX → MHTML → DOCX
      doc.save(temp_docx1)
      doc1 = Uniword::DocumentFactory.from_file(temp_docx1)
      doc1.save(temp_mhtml, format: :mhtml)
      doc2 = Uniword::DocumentFactory.from_file(temp_mhtml, format: :mhtml)
      doc2.save(temp_docx2)
      doc3 = Uniword::DocumentFactory.from_file(temp_docx2)

      # Verify table preserved
      expect(doc3.tables.count).to eq(doc.tables.count)
    end
  end

  describe 'Complex Document Conversion' do
    let(:mhtml_path) { "#{tmp_dir}/complex.doc" }
    let(:docx_path) { "#{tmp_dir}/complex.docx" }

    it 'converts complex document with mixed content' do
      doc = create_complex_document

      doc.text
      original_para_count = doc.paragraphs.count
      original_table_count = doc.tables.count

      # Convert to MHTML
      doc.save(mhtml_path, format: :mhtml)
      doc_mhtml = Uniword::DocumentFactory.from_file(mhtml_path, format: :mhtml)

      # Verify MHTML conversion
      expect(doc_mhtml.paragraphs.count).to eq(original_para_count)
      expect(doc_mhtml.tables.count).to eq(original_table_count)

      # Convert back to DOCX
      doc_mhtml.save(docx_path, format: :docx)
      doc_docx = Uniword::DocumentFactory.from_file(docx_path, format: :docx)

      # Verify final conversion
      expect(doc_docx.paragraphs.count).to eq(original_para_count)
      expect(doc_docx.tables.count).to eq(original_table_count)
    end

    it 'preserves heading styles across formats' do
      doc = Uniword::Document.new

      heading = Uniword::Paragraph.new(
        properties: Uniword::Wordprocessingml::ParagraphProperties.new(
          style: 'Heading1'
        )
      )
      heading.add_text('Heading')
      doc.body.paragraphs << heading

      # Convert DOCX → MHTML
      doc.save(docx_path)
      doc1 = Uniword::DocumentFactory.from_file(docx_path)
      doc1.save(mhtml_path, format: :mhtml)

      # Read MHTML
      doc2 = Uniword::DocumentFactory.from_file(mhtml_path, format: :mhtml)

      # Verify style preserved
      first_para = doc2.paragraphs.first
      expect(first_para.properties.style).to eq('Heading1')
    end
  end

  describe 'Fixture File Conversions' do
    it 'converts basic.docx to MHTML and back' do
      docx_fixture = "#{fixtures_dir}/basic.docx"
      skip 'Fixture file not found' unless File.exist?(docx_fixture)

      # Read fixture
      doc = Uniword::DocumentFactory.from_file(docx_fixture)
      original_text = doc.text

      # Convert to MHTML
      mhtml_path = "#{tmp_dir}/basic_converted.doc"
      doc.save(mhtml_path, format: :mhtml)

      # Read back
      doc_mhtml = Uniword::DocumentFactory.from_file(mhtml_path, format: :mhtml)

      # Verify text preserved
      expect(doc_mhtml.text).to eq(original_text)
    end

    it 'converts formatting.docx to MHTML' do
      docx_fixture = "#{fixtures_dir}/formatting.docx"
      skip 'Fixture file not found' unless File.exist?(docx_fixture)

      # Read fixture
      doc = Uniword::DocumentFactory.from_file(docx_fixture)
      bold_count_before = count_bold_runs(doc)

      # Convert to MHTML
      mhtml_path = "#{tmp_dir}/formatting_converted.doc"
      doc.save(mhtml_path, format: :mhtml)

      # Read back
      doc_mhtml = Uniword::DocumentFactory.from_file(mhtml_path, format: :mhtml)
      bold_count_after = count_bold_runs(doc_mhtml)

      # Verify formatting preserved
      expect(bold_count_after).to eq(bold_count_before)
    end

    it 'converts tables.docx to MHTML' do
      docx_fixture = "#{fixtures_dir}/tables.docx"
      skip 'Fixture file not found' unless File.exist?(docx_fixture)

      # Read fixture
      doc = Uniword::DocumentFactory.from_file(docx_fixture)
      table_count_before = doc.tables.count

      # Convert to MHTML
      mhtml_path = "#{tmp_dir}/tables_converted.doc"
      doc.save(mhtml_path, format: :mhtml)

      # Read back
      doc_mhtml = Uniword::DocumentFactory.from_file(mhtml_path, format: :mhtml)

      # Verify tables preserved
      expect(doc_mhtml.tables.count).to eq(table_count_before)
    end
  end

  describe 'Format Detection' do
    it 'auto-detects DOCX format for reading' do
      docx_fixture = "#{fixtures_dir}/basic.docx"
      skip 'Fixture file not found' unless File.exist?(docx_fixture)

      # Read without explicit format
      doc = Uniword::DocumentFactory.from_file(docx_fixture)

      expect(doc).to be_a(Uniword::Document)
      expect(doc.paragraphs.count).to be > 0
    end

    it 'auto-detects MHTML format for reading' do
      # Create MHTML file
      mhtml_path = "#{tmp_dir}/test.doc"
      doc = Uniword::Document.new
      doc.add_paragraph('Test')
      doc.save(mhtml_path, format: :mhtml)

      # Read without explicit format
      doc2 = Uniword::DocumentFactory.from_file(mhtml_path)

      expect(doc2).to be_a(Uniword::Document)
      expect(doc2.text).to include('Test')
    end

    it 'handles explicit format override' do
      # Create MHTML file with .mhtml extension
      mhtml_path = "#{tmp_dir}/test.mhtml"
      doc = Uniword::Document.new
      doc.add_paragraph('Test MHTML')
      doc.save(mhtml_path, format: :mhtml)

      # Read with explicit format
      doc2 = Uniword::DocumentFactory.from_file(mhtml_path, format: :mhtml)

      expect(doc2.text).to include('Test MHTML')
    end
  end

  # Helper methods
  private

  def extract_paragraph_text(paragraph)
    return '' unless paragraph.respond_to?(:runs)

    paragraph.runs.map do |run|
      run.respond_to?(:text) ? run.text : ''
    end.join
  end

  def create_formatted_document
    doc = Uniword::Document.new

    # Bold paragraph
    para1 = Uniword::Paragraph.new
    bold_run = Uniword::Run.new
    bold_run.text = 'Bold text'
    bold_run.properties = Uniword::Wordprocessingml::RunProperties.new(bold: true)
    para1.add_run(bold_run)
    doc.body.paragraphs << para1

    # Italic paragraph
    para2 = Uniword::Paragraph.new
    italic_run = Uniword::Run.new
    italic_run.text = 'Italic text'
    italic_run.properties = Uniword::Wordprocessingml::RunProperties.new(italic: true)
    para2.add_run(italic_run)
    doc.body.paragraphs << para2

    # Normal paragraph
    doc.add_paragraph('Normal text')

    doc
  end

  def create_document_with_table
    doc = Uniword::Document.new

    # Add paragraph
    doc.add_paragraph('Before table')

    # Add table
    table = Uniword::Table.new
    row = Uniword::TableRow.new
    cell = Uniword::TableCell.new
    cell_para = Uniword::Paragraph.new
    cell_para.add_text('Cell content')
    cell.add_paragraph(cell_para)
    row.add_cell(cell)
    table.add_row(row)
    doc.body.tables << table

    # Add paragraph after
    doc.add_paragraph('After table')

    doc
  end

  def create_complex_document
    doc = Uniword::Document.new

    # Heading
    heading = Uniword::Paragraph.new(
      properties: Uniword::Wordprocessingml::ParagraphProperties.new(
        style: 'Heading1'
      )
    )
    heading.add_text('Document Title')
    doc.body.paragraphs << heading

    # Formatted paragraph
    para1 = Uniword::Paragraph.new
    bold_run = Uniword::Run.new
    bold_run.text = 'Bold'
    bold_run.properties = Uniword::Wordprocessingml::RunProperties.new(bold: true)
    para1.add_run(bold_run)

    normal_run = Uniword::Run.new
    normal_run.text = ' and normal'
    para1.add_run(normal_run)
    doc.body.paragraphs << para1

    # Table
    table = Uniword::Table.new
    row = Uniword::TableRow.new
    cell = Uniword::TableCell.new
    cell_para = Uniword::Paragraph.new
    cell_para.add_text('Table data')
    cell.add_paragraph(cell_para)
    row.add_cell(cell)
    table.add_row(row)
    doc.body.tables << table

    # Final paragraph
    doc.add_paragraph('Conclusion')

    doc
  end

  def count_bold_runs(document)
    count = 0
    document.paragraphs.each do |para|
      next unless para.respond_to?(:runs)

      para.runs.each do |run|
        if run.respond_to?(:properties) && run.properties.respond_to?(:bold) && run.properties.bold
          count += 1
        end
      end
    end
    count
  end
end
