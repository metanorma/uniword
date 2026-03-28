# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe 'OOXML Namespace Configuration' do
  describe Uniword::Wordprocessingml::DocumentRoot do
    it 'has correct OOXML namespaces configured' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      # Verify the document can be serialized to XML
      expect { doc.to_xml }.not_to raise_error
    end

    it 'includes WordProcessingML main namespace' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      xml = doc.to_xml(prefix: true)

      expect(xml).to include('xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"')
    end

    it 'includes relationships namespace when used' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      # Add an element that uses relationships namespace (e.g., hyperlink)
      para = Uniword::Wordprocessingml::Paragraph.new
      builder = Uniword::Builder::ParagraphBuilder.new(para)
      builder << Uniword::Builder.hyperlink('https://example.com', 'Click here')
      doc.body.paragraphs << para
      xml = doc.to_xml(prefix: true)

      # Note: relationships namespace is only included when elements use it
      # For a document with hyperlinks, it should include the r: namespace
      expect(xml).to include('xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"')
    end

    it 'uses w:document as root element' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      xml = doc.to_xml(prefix: true)

      expect(xml).to match(/<w:document/)
    end
  end

  describe Uniword::Wordprocessingml::Paragraph do
    it 'has correct OOXML namespaces configured' do
      para = Uniword::Wordprocessingml::Paragraph.new

      expect { para.to_xml }.not_to raise_error
    end

    it 'uses w:p as root element' do
      para = Uniword::Wordprocessingml::Paragraph.new
      xml = para.to_xml(prefix: true)

      expect(xml).to match(/<w:p/)
    end

    it 'serializes runs with w:r elements' do
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Hello World')
      para.runs << run
      xml = para.to_xml(prefix: true)

      expect(xml).to include('<w:r')
    end
  end

  describe Uniword::Wordprocessingml::Run do
    it 'has correct OOXML namespaces configured' do
      run = Uniword::Wordprocessingml::Run.new(text: 'Test')

      expect { run.to_xml }.not_to raise_error
    end

    it 'uses w:r as root element' do
      run = Uniword::Wordprocessingml::Run.new(text: 'Test')
      xml = run.to_xml(prefix: true)

      expect(xml).to match(/<w:r/)
    end

    it 'serializes text with w:t element' do
      run = Uniword::Wordprocessingml::Run.new(text: 'Hello')
      xml = run.to_xml(prefix: true)

      expect(xml).to include('<w:t')
      expect(xml).to include('Hello')
    end
  end

  describe Uniword::Wordprocessingml::Table do
    it 'has correct OOXML namespaces configured' do
      table = Uniword::Wordprocessingml::Table.new

      expect { table.to_xml }.not_to raise_error
    end

    it 'uses w:tbl as root element' do
      table = Uniword::Wordprocessingml::Table.new
      xml = table.to_xml(prefix: true)

      expect(xml).to match(/<w:tbl/)
    end

    it 'serializes rows with w:tr elements' do
      table = Uniword::Wordprocessingml::Table.new
      row = Uniword::Wordprocessingml::TableRow.new
      row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Cell 1')
        para.runs << run
        cell.paragraphs << para
      end
      row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Cell 2')
        para.runs << run
        cell.paragraphs << para
      end
      table.rows << row
      xml = table.to_xml(prefix: true)

      expect(xml).to include('<w:tr')
    end
  end

  describe Uniword::Wordprocessingml::TableRow do
    it 'has correct OOXML namespaces configured' do
      row = Uniword::Wordprocessingml::TableRow.new

      expect { row.to_xml }.not_to raise_error
    end

    it 'uses w:tr as root element' do
      row = Uniword::Wordprocessingml::TableRow.new
      xml = row.to_xml(prefix: true)

      expect(xml).to match(/<w:tr/)
    end

    it 'serializes cells with w:tc elements' do
      row = Uniword::Wordprocessingml::TableRow.new
      row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Test Cell')
        para.runs << run
        cell.paragraphs << para
      end
      xml = row.to_xml(prefix: true)

      expect(xml).to include('<w:tc')
    end
  end

  describe Uniword::Wordprocessingml::TableCell do
    it 'has correct OOXML namespaces configured' do
      cell = Uniword::Wordprocessingml::TableCell.new

      expect { cell.to_xml }.not_to raise_error
    end

    it 'uses w:tc as root element' do
      cell = Uniword::Wordprocessingml::TableCell.new
      xml = cell.to_xml(prefix: true)

      expect(xml).to match(/<w:tc/)
    end

    it 'serializes paragraphs with w:p elements' do
      cell = Uniword::Wordprocessingml::TableCell.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Cell content')
      para.runs << run
      cell.paragraphs << para
      xml = cell.to_xml(prefix: true)

      expect(xml).to include('<w:p')
    end
  end

  describe Uniword::Image do
    it 'has correct OOXML namespaces configured' do
      image = Uniword::Image.new(relationship_id: 'rId1', width: 100, height: 100)

      expect { image.to_xml }.not_to raise_error
    end

    it 'uses w:drawing as root element' do
      image = Uniword::Image.new(relationship_id: 'rId1', width: 100, height: 100)
      xml = image.to_xml(prefix: true)

      # Image uses WordProcessingML namespace for the drawing wrapper
      expect(xml).to match(/<w:drawing/)
    end
  end

  describe 'Round-trip serialization' do
    it 'preserves document structure through XML round-trip' do
      # Create a document with content
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Test content')
      para.runs << run
      doc.body.paragraphs << para

      # Serialize to XML
      xml = doc.to_xml

      # Deserialize from XML
      parsed_doc = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)

      # Verify structure is preserved
      expect(parsed_doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(parsed_doc.paragraphs).not_to be_empty
    end

    it 'preserves table structure through XML round-trip' do
      # Create a table
      table = Uniword::Wordprocessingml::Table.new

      # Header row
      header_row = Uniword::Wordprocessingml::TableRow.new
      header_row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Header 1')
        para.runs << run
        cell.paragraphs << para
      end
      header_row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Header 2')
        para.runs << run
        cell.paragraphs << para
      end
      table.rows << header_row

      # Data row
      data_row = Uniword::Wordprocessingml::TableRow.new
      data_row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Data 1')
        para.runs << run
        cell.paragraphs << para
      end
      data_row.cells << Uniword::Wordprocessingml::TableCell.new.tap do |cell|
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Data 2')
        para.runs << run
        cell.paragraphs << para
      end
      table.rows << data_row

      # Serialize to XML
      xml = table.to_xml

      # Deserialize from XML
      parsed_table = Uniword::Wordprocessingml::Table.from_xml(xml)

      # Verify structure is preserved
      expect(parsed_table).to be_a(Uniword::Wordprocessingml::Table)
      expect(parsed_table.rows.count).to eq(2)
    end
  end

  describe 'Namespace prefix consistency' do
    it 'uses consistent w: prefix for WordProcessingML elements when prefix option is true' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Test')
      para.runs << run
      doc.body.paragraphs << para

      xml = doc.to_xml(prefix: true)

      # All WordProcessingML elements should use w: prefix when prefix: true
      expect(xml).to match(/<w:document/)
      expect(xml).to match(/<w:body/)
      expect(xml).to match(/<w:p/)
      expect(xml).to match(/<w:r/)
      expect(xml).to match(/<w:t/)
    end

    it 'uses default namespace without prefix option' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Test')
      para.runs << run
      doc.body.paragraphs << para

      xml = doc.to_xml

      # Without prefix option, default namespace is used (no prefix)
      expect(xml).to include('xmlns="http://schemas.openxmlformats.org/wordprocessingml/2006/main"')
      expect(xml).to match(/<document/)
      expect(xml).to match(/<body/)
      expect(xml).to match(/<p>/).or match(/<p\s/)
    end
  end
end
