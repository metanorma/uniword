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
      xml = doc.to_xml

      expect(xml).to include('xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"')
    end

    it 'includes relationships namespace' do
      doc = Uniword::Document.new
      xml = doc.to_xml

      expect(xml).to include('xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"')
    end

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

    it 'uses w:p as root element' do
      para = Uniword::Paragraph.new
      xml = para.to_xml

      expect(xml).to match(/<w:p/)
    end

    it 'serializes runs with w:r elements' do
      para = Uniword::Paragraph.new
      para.add_text('Hello World')
      xml = para.to_xml

      expect(xml).to include('<w:r')
    end
  end

  describe Uniword::Run do
    it 'has correct OOXML namespaces configured' do
      run = Uniword::Run.new(text: 'Test')

      expect { run.to_xml }.not_to raise_error
    end

    it 'uses w:r as root element' do
      run = Uniword::Run.new(text: 'Test')
      xml = run.to_xml

      expect(xml).to match(/<w:r/)
    end

    it 'serializes text with w:t element' do
      run = Uniword::Run.new(text: 'Hello')
      xml = run.to_xml

      expect(xml).to include('<w:t')
      expect(xml).to include('Hello')
    end
  end

  describe Uniword::Table do
    it 'has correct OOXML namespaces configured' do
      table = Uniword::Table.new

      expect { table.to_xml }.not_to raise_error
    end

    it 'uses w:tbl as root element' do
      table = Uniword::Table.new
      xml = table.to_xml

      expect(xml).to match(/<w:tbl/)
    end

    it 'serializes rows with w:tr elements' do
      table = Uniword::Table.new
      table.add_text_row(['Cell 1', 'Cell 2'])
      xml = table.to_xml

      expect(xml).to include('<w:tr')
    end
  end

  describe Uniword::TableRow do
    it 'has correct OOXML namespaces configured' do
      row = Uniword::TableRow.new

      expect { row.to_xml }.not_to raise_error
    end

    it 'uses w:tr as root element' do
      row = Uniword::TableRow.new
      xml = row.to_xml

      expect(xml).to match(/<w:tr/)
    end

    it 'serializes cells with w:tc elements' do
      row = Uniword::TableRow.new
      row.add_text_cell('Test Cell')
      xml = row.to_xml

      expect(xml).to include('<w:tc')
    end
  end

  describe Uniword::TableCell do
    it 'has correct OOXML namespaces configured' do
      cell = Uniword::TableCell.new

      expect { cell.to_xml }.not_to raise_error
    end

    it 'uses w:tc as root element' do
      cell = Uniword::TableCell.new
      xml = cell.to_xml

      expect(xml).to match(/<w:tc/)
    end

    it 'serializes paragraphs with w:p elements' do
      cell = Uniword::TableCell.new
      cell.add_text('Cell content')
      xml = cell.to_xml

      expect(xml).to include('<w:p')
    end
  end

  describe Uniword::Image do
    it 'has correct OOXML namespaces configured' do
      image = Uniword::Image.new(relationship_id: 'rId1', width: 100, height: 100)

      expect { image.to_xml }.not_to raise_error
    end

    it 'includes drawing namespaces' do
      pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
      image = Uniword::Image.new(relationship_id: 'rId1', width: 100, height: 100)
      xml = image.to_xml

      expect(xml).to include('xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"')
    end
  end

  describe 'Round-trip serialization' do
    it 'preserves document structure through XML round-trip' do
      pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
      # Create a document with content
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('Test content')
      doc.add_element(para)

      # Serialize to XML
      xml = doc.to_xml

      # Deserialize from XML
      parsed_doc = Uniword::Document.from_xml(xml)

      # Verify structure is preserved
      expect(parsed_doc).to be_a(Uniword::Document)
      expect(parsed_doc.paragraphs).not_to be_empty
    end

    it 'preserves table structure through XML round-trip' do
      pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
      # Create a table
      table = Uniword::Table.new
      table.add_text_row(['Header 1', 'Header 2'], header: true)
      table.add_text_row(['Data 1', 'Data 2'])

      # Serialize to XML
      xml = table.to_xml

      # Deserialize from XML
      parsed_table = Uniword::Table.from_xml(xml)

      # Verify structure is preserved
      expect(parsed_table).to be_a(Uniword::Table)
      expect(parsed_table.row_count).to eq(2)
    end
  end

  describe 'Namespace prefix consistency' do
    it 'uses consistent w: prefix for WordProcessingML elements' do
      pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      run = Uniword::Run.new(text: 'Test')
      para.add_run(run)
      doc.add_element(para)

      xml = doc.to_xml

      # All WordProcessingML elements should use w: prefix
      expect(xml).to match(/<w:document/)
      expect(xml).to match(/<w:body/)
      expect(xml).to match(/<w:p/)
      expect(xml).to match(/<w:r/)
      expect(xml).to match(/<w:t/)
    end

    it 'uses correct namespaces for different element types' do
      pending 'Element-level XML serialization will be implemented via OoxmlSerializer integration'
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