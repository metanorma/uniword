# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'MHTML Write Integration', type: :integration do
  let(:output_dir) { 'spec/tmp' }
  let(:output_path) { File.join(output_dir, 'test_output.doc') }

  before do
    FileUtils.mkdir_p(output_dir)
  end

  after do
    FileUtils.rm_f(output_path)
  end

  describe 'basic document generation' do
    it 'creates valid MHTML file with simple text' do
      document = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Hello, World!')
      document.add_element(para)

      document.save(output_path)

      expect(File.exist?(output_path)).to be true
      content = File.read(output_path, encoding: 'UTF-8')

      # Verify MIME structure
      expect(content).to include('MIME-Version: 1.0')
      expect(content).to include('Content-Type: multipart/related')
      expect(content).to include('boundary=')

      # Verify HTML content
      expect(content).to include('<!DOCTYPE html>')
      expect(content).to include('Hello, World!')

      # Verify Word-specific content
      expect(content).to include('xmlns:w="urn:schemas-microsoft-com:office:word"')
      expect(content).to include('class="WordSection1"')
    end

    it 'creates file with formatted text' do
      document = Uniword::Document.new
      para = Uniword::Paragraph.new

      # Bold text
      props = Uniword::Wordprocessingml::RunProperties.new(bold: true)
      para.add_text('Bold text', properties: props)

      document.add_element(para)
      document.save(output_path)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('font-weight:bold')
      expect(content).to include('Bold text')
    end

    it 'creates file with headings' do
      document = Uniword::Document.new

      # Add heading
      heading_props = Uniword::Wordprocessingml::ParagraphProperties.new(style: 'Heading1')
      heading = Uniword::Paragraph.new(properties: heading_props)
      heading.add_text('Document Title')
      document.add_element(heading)

      document.save(output_path)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('MsoHeading1')
      expect(content).to include('Document Title')
    end
  end

  describe 'table generation' do
    it 'creates file with table' do
      document = Uniword::Document.new

      table = Uniword::Table.new
      row = Uniword::TableRow.new
      cell = Uniword::TableCell.new
      para = Uniword::Paragraph.new
      para.add_text('Cell content')
      cell.add_paragraph(para)
      row.add_cell(cell)
      table.add_row(row)
      document.body.add_table(table)

      document.save(output_path)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('<table')
      expect(content).to include('<tr>')
      expect(content).to include('<td>')
      expect(content).to include('Cell content')
      expect(content).to include('</table>')
    end
  end

  describe 'CSS integration' do
    it 'includes Word CSS stylesheet' do
      document = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Test')
      document.add_element(para)

      document.save(output_path)

      content = File.read(output_path, encoding: 'UTF-8')

      # Check for Word CSS
      expect(content).to include('MsoNormal')
      expect(content).to include('@font-face')
      expect(content).to include('@page')
      expect(content).to include('@list')
    end
  end

  describe 'file size and structure' do
    it 'creates reasonably sized files' do
      document = Uniword::Document.new

      # Add multiple paragraphs
      10.times do |i|
        para = Uniword::Paragraph.new
        para.add_text("Paragraph #{i + 1}")
        document.add_element(para)
      end

      document.save(output_path)

      # File should exist and not be empty
      expect(File.exist?(output_path)).to be true
      file_size = File.size(output_path)
      expect(file_size).to be > 1000 # Should have substantial content
      expect(file_size).to be < 1_000_000 # But not unreasonably large
    end
  end

  describe 'format detection' do
    it 'detects .doc extension for MHTML format' do
      document = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Test')
      document.add_element(para)

      # Save with .doc extension
      doc_path = File.join(output_dir, 'test.doc')
      document.save(doc_path)

      expect(File.exist?(doc_path)).to be true
      content = File.read(doc_path, encoding: 'UTF-8')
      expect(content).to include('MIME-Version')

      FileUtils.rm_f(doc_path)
    end

    it 'detects .mhtml extension for MHTML format' do
      document = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Test')
      document.add_element(para)

      # Save with .mhtml extension
      mhtml_path = File.join(output_dir, 'test.mhtml')
      document.save(mhtml_path)

      expect(File.exist?(mhtml_path)).to be true
      content = File.read(mhtml_path, encoding: 'UTF-8')
      expect(content).to include('MIME-Version')

      FileUtils.rm_f(mhtml_path)
    end
  end

  describe 'character encoding' do
    it 'handles UTF-8 characters correctly' do
      document = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Hello 世界 مرحبا мир')
      document.add_element(para)

      document.save(output_path)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('Hello 世界 مرحبا мир')
      expect(content).to include('charset="utf-8"')
    end

    it 'escapes HTML special characters' do
      document = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('<script>alert("XSS")</script>')
      document.add_element(para)

      document.save(output_path)

      content = File.read(output_path, encoding: 'UTF-8')
      expect(content).to include('&lt;script&gt;')
      expect(content).not_to include('<script>alert')
    end
  end

  describe 'complex documents' do
    it 'creates complex document with multiple elements' do
      document = Uniword::Document.new

      # Heading
      h1_props = Uniword::Wordprocessingml::ParagraphProperties.new(style: 'Heading1')
      h1 = Uniword::Paragraph.new(properties: h1_props)
      h1.add_text('Main Title')
      document.add_element(h1)

      # Normal paragraph with formatting
      para1 = Uniword::Paragraph.new
      bold_props = Uniword::Wordprocessingml::RunProperties.new(bold: true)
      para1.add_text('Bold text ', properties: bold_props)
      italic_props = Uniword::Wordprocessingml::RunProperties.new(italic: true)
      para1.add_text('and italic text.', properties: italic_props)
      document.add_element(para1)

      # Table
      table = Uniword::Table.new
      2.times do |r|
        row = Uniword::TableRow.new
        3.times do |c|
          cell = Uniword::TableCell.new
          cell_para = Uniword::Paragraph.new
          cell_para.add_text("R#{r + 1}C#{c + 1}")
          cell.add_paragraph(cell_para)
          row.add_cell(cell)
        end
        table.add_row(row)
      end
      document.body.add_table(table)

      # Another paragraph
      para2 = Uniword::Paragraph.new
      para2.add_text('Conclusion paragraph.')
      document.add_element(para2)

      document.save(output_path)

      content = File.read(output_path, encoding: 'UTF-8')

      # Verify all elements present
      expect(content).to include('Main Title')
      expect(content).to include('Bold text')
      expect(content).to include('italic text')
      expect(content).to include('R1C1')
      expect(content).to include('R2C3')
      expect(content).to include('Conclusion paragraph')
    end
  end
end
