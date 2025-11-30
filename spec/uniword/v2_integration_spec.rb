# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe 'Uniword v2.0 Integration' do
  # Create temp directory for test files
  let(:temp_dir) { 'tmp/rspec' }

  before(:all) do
    FileUtils.mkdir_p('tmp/rspec')
  end

  after(:all) do
    FileUtils.rm_rf('tmp/rspec')
  end

  describe 'Document Creation' do
    it 'creates empty document' do
      doc = Uniword::Document.new
      expect(doc).to be_a(Uniword::Generated::Wordprocessingml::DocumentRoot)
      expect(doc.paragraphs).to be_empty
    end

    it 'adds paragraph with text' do
      doc = Uniword::Document.new
      para = doc.add_paragraph('Hello World')

      expect(para).to be_a(Uniword::Paragraph)
      expect(para.text).to eq('Hello World')
      expect(doc.paragraphs).to include(para)
    end

    it 'adds multiple paragraphs' do
      doc = Uniword::Document.new
      para1 = doc.add_paragraph('First')
      para2 = doc.add_paragraph('Second')

      expect(doc.paragraphs.length).to eq(2)
      expect(doc.paragraphs[0]).to eq(para1)
      expect(doc.paragraphs[1]).to eq(para2)
    end

    it 'adds formatted paragraph' do
      doc = Uniword::Document.new
      para = doc.add_paragraph('Bold text', bold: true)

      expect(para.runs.first.properties).not_to be_nil
      expect(para.runs.first.properties.bold).to be_truthy
    end
  end

  describe 'Serialization' do
    it 'serializes to valid XML' do
      doc = Uniword::Document.new
      doc.add_paragraph('Test paragraph')

      xml = doc.to_xml

      expect(xml).to be_a(String)
      expect(xml).to include('<document')
      expect(xml).to include('<body>')
      expect(xml).to include('<p>')
      expect(xml).to include('<t>Test paragraph</t>')
    end

    it 'serializes empty document' do
      doc = Uniword::Document.new
      xml = doc.to_xml

      expect(xml).to include('<document')
      expect(xml).to include('xmlns=')
    end

    it 'serializes formatted text' do
      doc = Uniword::Document.new
      doc.add_paragraph('Bold', bold: true)
      doc.add_paragraph('Italic', italic: true)

      xml = doc.to_xml
      expect(xml).to include('<b>true</b>')
      expect(xml).to include('<i>true</i>')
    end
  end

  describe 'Deserialization' do
    it 'deserializes from XML' do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p>
              <w:r>
                <w:t>Test paragraph</w:t>
              </w:r>
            </w:p>
          </w:body>
        </w:document>
      XML

      doc = Uniword::Generated::Wordprocessingml::DocumentRoot.from_xml(xml)

      expect(doc.body).not_to be_nil
      expect(doc.body.paragraphs.length).to eq(1)
      expect(doc.text).to include('Test paragraph')
    end

    it 'deserializes multiple paragraphs' do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p>
              <w:r><w:t>First</w:t></w:r>
            </w:p>
            <w:p>
              <w:r><w:t>Second</w:t></w:r>
            </w:p>
          </w:body>
        </w:document>
      XML

      doc = Uniword::Generated::Wordprocessingml::DocumentRoot.from_xml(xml)

      expect(doc.paragraphs.length).to eq(2)
      expect(doc.text).to include('First')
      expect(doc.text).to include('Second')
    end
  end

  describe 'Round-Trip' do
    it 'preserves content through save/load' do
      # Create document
      doc1 = Uniword::Document.new
      doc1.add_paragraph('First paragraph')
      doc1.add_paragraph('Second paragraph')

      # Save
      path = File.join(temp_dir, 'roundtrip_test.docx')
      doc1.save(path)

      # Verify file exists
      expect(File.exist?(path)).to be true
      expect(File.size(path)).to be > 0

      # Load
      doc2 = Uniword.load(path)

      # Verify structure
      expect(doc2).to be_a(Uniword::Document)
      expect(doc2.paragraphs.length).to eq(2)

      # Verify content
      text = doc2.text
      expect(text).to include('First paragraph')
      expect(text).to include('Second paragraph')
    end

    it 'preserves formatting through round-trip' do
      doc1 = Uniword::Document.new
      doc1.add_paragraph('Bold text', bold: true)
      doc1.add_paragraph('Italic text', italic: true)

      path = File.join(temp_dir, 'formatting_test.docx')
      doc1.save(path)

      doc2 = Uniword.load(path)

      expect(doc2.paragraphs.length).to eq(2)
      expect(doc2.text).to include('Bold text')
      expect(doc2.text).to include('Italic text')
    end

    it 'handles empty document round-trip' do
      doc1 = Uniword::Document.new

      path = File.join(temp_dir, 'empty_test.docx')
      doc1.save(path)

      doc2 = Uniword.load(path)

      expect(doc2.paragraphs).to be_empty
    end
  end

  describe 'Extension Methods' do
    let(:doc) { Uniword::Document.new }

    describe '#add_paragraph' do
      it 'adds paragraph to document' do
        para = doc.add_paragraph('Test')
        expect(doc.paragraphs).to include(para)
      end

      it 'returns the created paragraph' do
        para = doc.add_paragraph('Test')
        expect(para).to be_a(Uniword::Paragraph)
      end

      it 'accepts formatting options' do
        para = doc.add_paragraph('Test', bold: true, italic: true)
        run = para.runs.first

        expect(run.properties.bold).to be_truthy
        expect(run.properties.italic).to be_truthy
      end
    end

    describe '#add_table' do
      it 'adds table to document' do
        table = doc.add_table(2, 3)
        expect(doc.tables).to include(table)
      end

      it 'creates table with specified dimensions' do
        table = doc.add_table(2, 3)
        expect(table.rows.length).to eq(2)
        expect(table.rows.first.cells.length).to eq(3)
      end
    end

    describe '#text' do
      it 'extracts combined text from paragraphs' do
        doc.add_paragraph('First')
        doc.add_paragraph('Second')

        text = doc.text
        expect(text).to include('First')
        expect(text).to include('Second')
      end

      it 'returns empty string for empty document' do
        expect(doc.text).to eq('')
      end
    end

    describe 'Paragraph#add_text' do
      it 'adds text run to paragraph' do
        para = doc.add_paragraph
        para.add_text('Part 1')
        para.add_text(' Part 2')

        expect(para.text).to eq('Part 1 Part 2')
      end

      it 'accepts formatting options' do
        para = doc.add_paragraph
        para.add_text('Bold', bold: true)

        expect(para.runs.first.properties.bold).to be_truthy
      end
    end
  end

  describe 'Module-Level Convenience Methods' do
    describe 'Uniword.new' do
      it 'creates new document' do
        doc = Uniword.new
        expect(doc).to be_a(Uniword::Document)
      end
    end

    describe 'Uniword.load' do
      it 'loads document from file' do
        # Create a test file
        doc1 = Uniword::Document.new
        doc1.add_paragraph('Test content')

        path = File.join(temp_dir, 'load_test.docx')
        doc1.save(path)

        # Load it
        doc2 = Uniword.load(path)

        expect(doc2).to be_a(Uniword::Document)
        expect(doc2.text).to include('Test content')
      end
    end

    describe 'Uniword.open' do
      it 'is an alias for load' do
        doc1 = Uniword::Document.new
        doc1.add_paragraph('Test')

        path = File.join(temp_dir, 'open_test.docx')
        doc1.save(path)

        doc2 = Uniword.open(path)

        expect(doc2.text).to include('Test')
      end
    end
  end

  describe 'Generated Classes Integration' do
    it 'Document is aliased to generated class' do
      expect(Uniword::Document).to eq(Uniword::Generated::Wordprocessingml::DocumentRoot)
    end

    it 'Paragraph is aliased to generated class' do
      expect(Uniword::Paragraph).to eq(Uniword::Generated::Wordprocessingml::Paragraph)
    end

    it 'Run is aliased to generated class' do
      expect(Uniword::Run).to eq(Uniword::Generated::Wordprocessingml::Run)
    end

    it 'generated classes have lutaml-model serialization' do
      doc = Uniword::Document.new

      expect(doc).to respond_to(:to_xml)
      expect(doc.class).to respond_to(:from_xml)
    end
  end
end
