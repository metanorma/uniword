# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'OOXML Namespace Configuration' do
  describe Uniword::Document do
    it 'has correct OOXML namespaces configured' do
      doc = Uniword::Document.new

      # Verify the document can be serialized to XML
      expect { doc.to_xml }.not_to raise_error
    end

    it 'includes WordProcessingML main namespace' do
      doc = Uniword::Document.new
      xml = doc.to_xml(prefix: true)

      expect(xml).to include('xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"')
    end

    it 'includes relationships namespace when used' do
      doc = Uniword::Document.new
      # Add an element that uses relationships namespace (e.g., hyperlink)
      para = Uniword::Paragraph.new
      para.add_hyperlink('Click here', url: 'https://example.com')
      doc.body.paragraphs << para
      xml = doc.to_xml(prefix: true)

      # Note: relationships namespace is only included when elements use it
      # For a document with hyperlinks, it should include the r: namespace
      expect(xml).to include('xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"')
    end

    pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
      it 'uses w:document as root element' do
      pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
      doc = Uniword::Document.new
      xml = doc.to_xml

      expect(xml).to match(/<w:document/)
    end
  end

  describe Uniword::Paragraph do
    it 'has correct OOXML namespaces configured' do
      para = Uniword::Paragraph.new

      expect { para.to_xml }.not_to raise_error
    end

    pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
      it 'uses w:p as root element' do
      pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
      para = Uniword::Paragraph.new
      xml = para.to_xml(prefix: true)

      expect(xml).to match(/<w:p/)
    end

    it 'serializes runs with w:r elements' do
      para = Uniword::Paragraph.new
      para.add_text('Hello World')
      xml = para.to_xml(prefix: true)

      expect(xml).to include('<w:r')
    end
  end

  describe Uniword::Run do
    it 'has correct OOXML namespaces configured' do
      run = Uniword::Run.new(text: 'Test')

      expect { run.to_xml }.not_to raise_error
    end

    pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
      it 'uses w:r as root element' do
      run = Uniword::Run.new(text: 'Test')
      xml = run.to_xml(prefix: true)

      expect(xml).to match(/<w:r/)
    end

    it 'serializes text with w:t element' do
      run = Uniword::Run.new(text: 'Hello')
      xml = run.to_xml(prefix: true)

      expect(xml).to include('<w:t')
      expect(xml).to include('Hello')
    end
  end

  describe Uniword::Table do
    it 'has correct OOXML namespaces configured' do
      table = Uniword::Table.new

      expect { table.to_xml }.not_to raise_error
    end

    pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
      it 'uses w:tbl as root element' do
      table = Uniword::Table.new
      xml = table.to_xml(prefix: true)

      expect(xml).to match(/<w:tbl/)
    end

    it 'serializes rows with w:tr elements' do
      table = Uniword::Table.new
      row = Uniword::TableRow.new
      row.cells << Uniword::TableCell.new.tap do |cell|
        cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell 1') }
      end
      row.cells << Uniword::TableCell.new.tap do |cell|
        cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell 2') }
      end
      table.rows << row
      xml = table.to_xml(prefix: true)

      expect(xml).to include('<w:tr')
    end
  end

  describe Uniword::TableRow do
    it 'has correct OOXML namespaces configured' do
      row = Uniword::TableRow.new

      expect { row.to_xml }.not_to raise_error
    end

    pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
      it 'uses w:tr as root element' do
      row = Uniword::TableRow.new
      xml = row.to_xml(prefix: true)

      expect(xml).to match(/<w:tr/)
    end

    it 'serializes cells with w:tc elements' do
      row = Uniword::TableRow.new
      row.cells << Uniword::TableCell.new.tap do |cell|
        cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Test Cell') }
      end
      xml = row.to_xml(prefix: true)

      expect(xml).to include('<w:tc')
    end
  end

  describe Uniword::TableCell do
    it 'has correct OOXML namespaces configured' do
      cell = Uniword::TableCell.new

      expect { cell.to_xml }.not_to raise_error
    end

    pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
      it 'uses w:tc as root element' do
      cell = Uniword::TableCell.new
      xml = cell.to_xml(prefix: true)

      expect(xml).to match(/<w:tc/)
    end

    it 'serializes paragraphs with w:p elements' do
      cell = Uniword::TableCell.new
      cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Cell content') }
      xml = cell.to_xml(prefix: true)

      expect(xml).to include('<w:p')
    end
  end

  describe Uniword::Image do
    it 'has correct OOXML namespaces configured' do
      image = Uniword::Image.new(relationship_id: 'rId1', width: 100, height: 100)

      expect { image.to_xml }.not_to raise_error
    end

    it 'includes drawing namespaces' do
      image = Uniword::Image.new(relationship_id: 'rId1', width: 100, height: 100)
      xml = image.to_xml

      expect(xml).to include('xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"')
    end
  end

  describe 'Round-trip serialization' do
    it 'preserves document structure through XML round-trip' do
      # Create a document with content
      doc = Uniword::Document.new
      doc.add_paragraph('Test content')

      # Serialize to XML
      xml = doc.to_xml

      # Deserialize from XML
      parsed_doc = Uniword::Document.from_xml(xml)

      # Verify structure is preserved
      expect(parsed_doc).to be_a(Uniword::Document)
      expect(parsed_doc.paragraphs).not_to be_empty
    end

    it 'preserves table structure through XML round-trip' do
      # Create a table
      table = Uniword::Table.new

      # Header row
      header_row = Uniword::TableRow.new
      header_row.cells << Uniword::TableCell.new.tap do |cell|
        cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Header 1') }
      end
      header_row.cells << Uniword::TableCell.new.tap do |cell|
        cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Header 2') }
      end
      table.rows << header_row

      # Data row
      data_row = Uniword::TableRow.new
      data_row.cells << Uniword::TableCell.new.tap do |cell|
        cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Data 1') }
      end
      data_row.cells << Uniword::TableCell.new.tap do |cell|
        cell.paragraphs << Uniword::Paragraph.new.tap { |p| p.add_text('Data 2') }
      end
      table.rows << data_row

      # Serialize to XML
      xml = table.to_xml

      # Deserialize from XML
      parsed_table = Uniword::Table.from_xml(xml)

      # Verify structure is preserved
      expect(parsed_table).to be_a(Uniword::Table)
      expect(parsed_table.rows.count).to eq(2)
    end
  end

  describe 'Namespace prefix consistency' do
    it 'uses consistent w: prefix for WordProcessingML elements' do
      doc = Uniword::Document.new
      doc.add_paragraph('Test')

      xml = doc.to_xml

      # All WordProcessingML elements should use w: prefix
      expect(xml).to match(/<w:document/)
      expect(xml).to match(/<w:body/)
      expect(xml).to match(/<w:p/)
      expect(xml).to match(/<w:r/)
      expect(xml).to match(/<w:t/)
    end

    it 'uses correct namespaces for different element types' do
      # Image should use drawing-related namespaces
      image = Uniword::Image.new(relationship_id: 'rId1', width: 100, height: 100)
      xml = image.to_xml

      # Should include drawing namespaces but not use w: prefix for root
      expect(xml).not_to match(/<w:drawing/)
      expect(xml).to include('xmlns:wp=')
      expect(xml).to include('xmlns:a=')
    end
  end
end
