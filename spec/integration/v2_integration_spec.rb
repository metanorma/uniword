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
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(doc.paragraphs).to be_empty
    end

    it 'adds paragraph with text' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Hello World')
      para.runs << run
      doc.body.paragraphs << para

      expect(para).to be_a(Uniword::Wordprocessingml::Paragraph)
      expect(para.text).to eq('Hello World')
      expect(doc.paragraphs).to include(para)
    end

    it 'adds multiple paragraphs' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'First')
      para1.runs << run1
      doc.body.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Second')
      para2.runs << run2
      doc.body.paragraphs << para2

      expect(doc.paragraphs.length).to eq(2)
      expect(doc.paragraphs[0]).to eq(para1)
      expect(doc.paragraphs[1]).to eq(para2)
    end

    it 'adds formatted paragraph' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Bold text')
      run.properties = Uniword::Wordprocessingml::RunProperties.new(bold: true)
      para.runs << run
      doc.body.paragraphs << para

      expect(para.runs.first.properties).not_to be_nil
      expect(para.runs.first.properties).to be_bold
    end
  end

  describe 'Serialization' do
    it 'serializes to valid XML' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Test paragraph')
      para.runs << run
      doc.body.paragraphs << para

      xml = doc.to_xml

      expect(xml).to be_a(String)
      expect(xml).to include('<document')
      expect(xml).to include('<body>')
      expect(xml).to include('<p>')
      expect(xml).to include('<t>Test paragraph</t>')
    end

    it 'serializes empty document' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      xml = doc.to_xml

      expect(xml).to include('<document')
      expect(xml).to include('xmlns=')
    end

    it 'serializes formatted text' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Bold')
      run1.properties = Uniword::Wordprocessingml::RunProperties.new(bold: true)
      para1.runs << run1
      doc.body.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Italic')
      run2.properties = Uniword::Wordprocessingml::RunProperties.new(italic: true)
      para2.runs << run2
      doc.body.paragraphs << para2

      xml = doc.to_xml
      # OOXML canonical form: <b/> not <b>true</b>
      expect(xml).to include('<b/>')
      expect(xml).to include('<i/>')
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

      doc = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)

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

      doc = Uniword::Wordprocessingml::DocumentRoot.from_xml(xml)

      expect(doc.paragraphs.length).to eq(2)
      expect(doc.text).to include('First')
      expect(doc.text).to include('Second')
    end
  end

  describe 'Round-Trip' do
    it 'preserves content through save/load' do
      # Create document
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'First paragraph')
      para1.runs << run1
      doc1.body.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Second paragraph')
      para2.runs << run2
      doc1.body.paragraphs << para2

      # Save
      path = File.join(temp_dir, 'roundtrip_test.docx')
      doc1.save(path)

      # Verify file exists
      expect(File.exist?(path)).to be true
      expect(File.size(path)).to be > 0

      # Load
      doc2 = Uniword.load(path)

      # Verify structure
      expect(doc2).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      expect(doc2.paragraphs.length).to eq(2)

      # Verify content
      text = doc2.text
      expect(text).to include('First paragraph')
      expect(text).to include('Second paragraph')
    end

    it 'preserves formatting through round-trip' do
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new
      para1 = Uniword::Wordprocessingml::Paragraph.new
      run1 = Uniword::Wordprocessingml::Run.new(text: 'Bold text')
      run1.properties = Uniword::Wordprocessingml::RunProperties.new(bold: true)
      para1.runs << run1
      doc1.body.paragraphs << para1
      para2 = Uniword::Wordprocessingml::Paragraph.new
      run2 = Uniword::Wordprocessingml::Run.new(text: 'Italic text')
      run2.properties = Uniword::Wordprocessingml::RunProperties.new(italic: true)
      para2.runs << run2
      doc1.body.paragraphs << para2

      path = File.join(temp_dir, 'formatting_test.docx')
      doc1.save(path)

      doc2 = Uniword.load(path)

      expect(doc2.paragraphs.length).to eq(2)
      expect(doc2.text).to include('Bold text')
      expect(doc2.text).to include('Italic text')
    end

    it 'handles empty document round-trip' do
      doc1 = Uniword::Wordprocessingml::DocumentRoot.new

      path = File.join(temp_dir, 'empty_test.docx')
      doc1.save(path)

      doc2 = Uniword.load(path)

      expect(doc2.paragraphs).to be_empty
    end
  end

  describe 'Extension Methods' do
    let(:doc) { Uniword::Wordprocessingml::DocumentRoot.new }

    describe '#add_paragraph' do
      it 'adds paragraph to document' do
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Test')
        para.runs << run
        doc.body.paragraphs << para
        expect(doc.paragraphs).to include(para)
      end

      it 'returns the created paragraph' do
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Test')
        para.runs << run
        doc.body.paragraphs << para
        expect(para).to be_a(Uniword::Wordprocessingml::Paragraph)
      end

      it 'accepts formatting options' do
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Test')
        run.properties = Uniword::Wordprocessingml::RunProperties.new(bold: true, italic: true)
        para.runs << run
        doc.body.paragraphs << para
        run = para.runs.first

        expect(run.properties).to be_bold
        expect(run.properties).to be_italic
      end
    end

    describe '#add_table' do
      it 'adds table to document' do
        table = Uniword::Wordprocessingml::Table.new
        2.times do
          row = Uniword::Wordprocessingml::TableRow.new
          3.times do
            row.cells << Uniword::Wordprocessingml::TableCell.new
          end
          table.rows << row
        end
        doc.body.tables << table
        expect(doc.tables).to include(table)
      end

      it 'creates table with specified dimensions' do
        table = Uniword::Wordprocessingml::Table.new
        2.times do
          row = Uniword::Wordprocessingml::TableRow.new
          3.times do
            row.cells << Uniword::Wordprocessingml::TableCell.new
          end
          table.rows << row
        end
        doc.body.tables << table
        expect(table.rows.length).to eq(2)
        expect(table.rows.first.cells.length).to eq(3)
      end
    end

    describe '#text' do
      it 'extracts combined text from paragraphs' do
        para1 = Uniword::Wordprocessingml::Paragraph.new
        run1 = Uniword::Wordprocessingml::Run.new(text: 'First')
        para1.runs << run1
        doc.body.paragraphs << para1
        para2 = Uniword::Wordprocessingml::Paragraph.new
        run2 = Uniword::Wordprocessingml::Run.new(text: 'Second')
        para2.runs << run2
        doc.body.paragraphs << para2

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
        para = Uniword::Wordprocessingml::Paragraph.new
        doc.body.paragraphs << para
        run1 = Uniword::Wordprocessingml::Run.new(text: 'Part 1')
        para.runs << run1
        run2 = Uniword::Wordprocessingml::Run.new(text: ' Part 2')
        para.runs << run2

        expect(para.text).to eq('Part 1 Part 2')
      end

      it 'accepts formatting options' do
        para = Uniword::Wordprocessingml::Paragraph.new
        doc.body.paragraphs << para
        run = Uniword::Wordprocessingml::Run.new(text: 'Bold')
        run.properties = Uniword::Wordprocessingml::RunProperties.new(bold: true)
        para.runs << run

        expect(para.runs.first.properties).to be_bold
      end
    end
  end

  describe 'Module-Level Convenience Methods' do
    describe 'Uniword.new' do
      it 'creates new document' do
        doc = Uniword.new
        expect(doc).to be_a(Uniword::Wordprocessingml::DocumentRoot)
      end
    end

    describe 'Uniword.load' do
      it 'loads document from file' do
        # Create a test file
        doc1 = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Test content')
        para.runs << run
        doc1.body.paragraphs << para

        path = File.join(temp_dir, 'load_test.docx')
        doc1.save(path)

        # Load it
        doc2 = Uniword.load(path)

        expect(doc2).to be_a(Uniword::Wordprocessingml::DocumentRoot)
        expect(doc2.text).to include('Test content')
      end
    end

    describe 'Uniword.open' do
      it 'is an alias for load' do
        doc1 = Uniword::Wordprocessingml::DocumentRoot.new
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: 'Test')
        para.runs << run
        doc1.body.paragraphs << para

        path = File.join(temp_dir, 'open_test.docx')
        doc1.save(path)

        doc2 = Uniword.load(path)

        expect(doc2.text).to include('Test')
      end
    end
  end

  describe 'Generated Classes Integration' do
    it 'Document is aliased to generated class' do
      expect(Uniword::Wordprocessingml::DocumentRoot).to eq(Uniword::Wordprocessingml::DocumentRoot)
    end

    it 'Paragraph is aliased to generated class' do
      expect(Uniword::Wordprocessingml::Paragraph).to eq(Uniword::Wordprocessingml::Paragraph)
    end

    it 'Run is aliased to generated class' do
      expect(Uniword::Wordprocessingml::Run).to eq(Uniword::Wordprocessingml::Run)
    end

    it 'generated classes have lutaml-model serialization' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      expect(doc).to respond_to(:to_xml)
      expect(doc.class).to respond_to(:from_xml)
    end
  end
end
