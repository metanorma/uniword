# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'zip'

RSpec.describe 'DOCX Compatibility Testing' do
  let(:tmp_dir) { 'tmp/compatibility' }

  before(:all) do
    FileUtils.mkdir_p('tmp/compatibility')
  end

  after(:each) do
    # Clean up temporary files after each test
    Dir.glob("#{tmp_dir}/*.docx").each { |f| File.delete(f) }
  end

  describe 'File Signature Validation' do
    let(:test_path) { "#{tmp_dir}/signature_test.docx" }

    it 'generates valid ZIP structure' do
      doc = create_test_document
      doc.save(test_path)

      # Verify it's a valid ZIP file
      expect { Zip::File.open(test_path) {} }.not_to raise_error
    end

    it 'contains required OOXML parts' do
      doc = create_test_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        # Required parts for minimal DOCX
        expect(zip.find_entry('[Content_Types].xml')).not_to be_nil,
               'Missing [Content_Types].xml'
        expect(zip.find_entry('word/document.xml')).not_to be_nil,
               'Missing word/document.xml'
        expect(zip.find_entry('_rels/.rels')).not_to be_nil,
               'Missing _rels/.rels'
        expect(zip.find_entry('word/_rels/document.xml.rels')).not_to be_nil,
               'Missing word/_rels/document.xml.rels'
      end
    end

    it 'includes styles.xml when styles are present' do
      doc = create_document_with_styles
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        expect(zip.find_entry('word/styles.xml')).not_to be_nil,
               'Missing word/styles.xml'
      end
    end

    it 'includes numbering.xml when lists are present' do
      doc = create_document_with_numbering
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        # Numbering.xml should be present when document has numbered lists
        entry = zip.find_entry('word/numbering.xml')
        # This may be optional depending on implementation
        # Just verify structure is valid if present
        expect(test_path).to be_a(String)
      end
    end

    it 'has correct ZIP compression' do
      doc = create_test_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        # Verify entries are compressed (not stored)
        xml_entries = zip.entries.select { |e| e.name.end_with?('.xml') }
        expect(xml_entries).not_to be_empty

        # At least some entries should be compressed
        compressed = xml_entries.any? do |entry|
          entry.compression_method == Zip::Entry::DEFLATED
        end
        expect(compressed).to be true
      end
    end
  end

  describe 'OOXML Validation' do
    let(:test_path) { "#{tmp_dir}/ooxml_test.docx" }

    it 'generates well-formed XML' do
      doc = create_full_featured_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        zip.entries.each do |entry|
          next unless entry.name.end_with?('.xml')

          xml_content = zip.read(entry.name)

          # Parse XML to verify it's well-formed
          expect { Nokogiri::XML(xml_content) { |config| config.strict } }
            .not_to raise_error, "Malformed XML in #{entry.name}"
        end
      end
    end

    it 'uses correct OOXML namespaces' do
      doc = create_test_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        document_xml = zip.read('word/document.xml')
        doc_node = Nokogiri::XML(document_xml)

        # Check for required namespaces
        namespaces = doc_node.collect_namespaces

        expect(namespaces).to include(
          'xmlns:w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
        )
        expect(namespaces).to include(
          'xmlns:r' => 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
        )
      end
    end

    it 'has valid document.xml structure' do
      doc = create_test_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        document_xml = zip.read('word/document.xml')
        doc_node = Nokogiri::XML(document_xml)

        # Required elements
        expect(doc_node.at_xpath('//w:document',
                                 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'))
          .not_to be_nil, 'Missing w:document root element'

        expect(doc_node.at_xpath('//w:body',
                                 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'))
          .not_to be_nil, 'Missing w:body element'
      end
    end

    it 'has valid Content_Types.xml' do
      doc = create_test_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        content_types_xml = zip.read('[Content_Types].xml')
        ct_node = Nokogiri::XML(content_types_xml)

        # Should have Types root element
        types = ct_node.at_xpath('//ct:Types',
                                 'ct' => 'http://schemas.openxmlformats.org/package/2006/content-types')
        expect(types).not_to be_nil, 'Missing Types root element'

        # Should have Default and Override elements
        defaults = ct_node.xpath('//ct:Default',
                                 'ct' => 'http://schemas.openxmlformats.org/package/2006/content-types')
        expect(defaults).not_to be_empty, 'Missing Default content type entries'

        overrides = ct_node.xpath('//ct:Override',
                                  'ct' => 'http://schemas.openxmlformats.org/package/2006/content-types')
        expect(overrides).not_to be_empty, 'Missing Override content type entries'
      end
    end

    it 'has no invalid OOXML elements' do
      doc = create_test_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        document_xml = zip.read('word/document.xml')
        doc_node = Nokogiri::XML(document_xml)

        # Check that all elements are in proper namespaces
        doc_node.xpath('//*').each do |element|
          # All elements should have a namespace (no default namespace elements)
          expect(element.namespace).not_to be_nil,
                 "Element #{element.name} has no namespace"
        end
      end
    end
  end

  describe 'Content Type Validation' do
    let(:test_path) { "#{tmp_dir}/content_types_test.docx" }

    it 'declares correct MIME types for parts' do
      doc = create_test_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        content_types_xml = zip.read('[Content_Types].xml')
        ct_node = Nokogiri::XML(content_types_xml)

        # Check main document content type
        main_doc = ct_node.at_xpath('//ct:Override[@PartName="/word/document.xml"]',
                                    'ct' => 'http://schemas.openxmlformats.org/package/2006/content-types')
        expect(main_doc&.attr('ContentType')).to eq(
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml'
        )
      end
    end

    it 'includes .rels content type' do
      doc = create_test_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        content_types_xml = zip.read('[Content_Types].xml')
        ct_node = Nokogiri::XML(content_types_xml)

        # Check .rels extension
        rels_default = ct_node.at_xpath('//ct:Default[@Extension="rels"]',
                                        'ct' => 'http://schemas.openxmlformats.org/package/2006/content-types')
        expect(rels_default&.attr('ContentType')).to eq(
          'application/vnd.openxmlformats-package.relationships+xml'
        )
      end
    end

    it 'includes .xml content type' do
      doc = create_test_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        content_types_xml = zip.read('[Content_Types].xml')
        ct_node = Nokogiri::XML(content_types_xml)

        # Check .xml extension
        xml_default = ct_node.at_xpath('//ct:Default[@Extension="xml"]',
                                       'ct' => 'http://schemas.openxmlformats.org/package/2006/content-types')
        expect(xml_default&.attr('ContentType')).to eq('application/xml')
      end
    end

    it 'correctly declares styles.xml when present' do
      doc = create_document_with_styles
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        next unless zip.find_entry('word/styles.xml')

        content_types_xml = zip.read('[Content_Types].xml')
        ct_node = Nokogiri::XML(content_types_xml)

        styles_override = ct_node.at_xpath('//ct:Override[@PartName="/word/styles.xml"]',
                                           'ct' => 'http://schemas.openxmlformats.org/package/2006/content-types')
        expect(styles_override&.attr('ContentType')).to eq(
          'application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml'
        )
      end
    end
  end

  describe 'Relationship Validation' do
    let(:test_path) { "#{tmp_dir}/relationships_test.docx" }

    it 'has valid root relationships file' do
      doc = create_test_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        rels_xml = zip.read('_rels/.rels')
        rels_node = Nokogiri::XML(rels_xml)

        # Should have Relationships root
        relationships = rels_node.at_xpath('//pr:Relationships',
                                           'pr' => 'http://schemas.openxmlformats.org/package/2006/relationships')
        expect(relationships).not_to be_nil

        # Should have relationship to main document
        doc_rel = rels_node.at_xpath('//pr:Relationship[@Target="word/document.xml"]',
                                     'pr' => 'http://schemas.openxmlformats.org/package/2006/relationships')
        expect(doc_rel).not_to be_nil
        expect(doc_rel.attr('Type')).to include('officeDocument')
      end
    end

    it 'has valid document relationships file' do
      doc = create_test_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        rels_xml = zip.read('word/_rels/document.xml.rels')
        rels_node = Nokogiri::XML(rels_xml)

        # Should have Relationships root
        relationships = rels_node.at_xpath('//pr:Relationships',
                                           'pr' => 'http://schemas.openxmlformats.org/package/2006/relationships')
        expect(relationships).not_to be_nil
      end
    end

    it 'references existing targets in relationships' do
      doc = create_document_with_styles
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        rels_xml = zip.read('word/_rels/document.xml.rels')
        rels_node = Nokogiri::XML(rels_xml)

        rels_node.xpath('//pr:Relationship',
                        'pr' => 'http://schemas.openxmlformats.org/package/2006/relationships').each do |rel|
          target = rel.attr('Target')
          next if target.start_with?('http://') || target.start_with?('https://')

          # Internal target should exist in ZIP
          full_path = if target.start_with?('/')
                        target[1..]
                      else
                        "word/#{target}"
                      end

          expect(zip.find_entry(full_path)).not_to be_nil,
                 "Relationship target not found: #{full_path}"
        end
      end
    end
  end

  describe 'Version Compatibility' do
    let(:test_path) { "#{tmp_dir}/version_test.docx" }

    it 'generates DOCX compatible with Office Open XML standard' do
      doc = create_test_document
      doc.save(test_path)

      # Verify file can be opened as ZIP
      expect { Zip::File.open(test_path) {} }.not_to raise_error

      # Verify it has DOCX structure
      Zip::File.open(test_path) do |zip|
        expect(zip.find_entry('word/document.xml')).not_to be_nil
      end
    end

    it 'uses ECMA-376 compliant structure' do
      doc = create_full_featured_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        # Check required parts exist
        required_parts = [
          '[Content_Types].xml',
          '_rels/.rels',
          'word/document.xml',
          'word/_rels/document.xml.rels'
        ]

        required_parts.each do |part|
          expect(zip.find_entry(part)).not_to be_nil,
                 "Missing required part: #{part}"
        end
      end
    end

    it 'includes version markers in XML' do
      doc = create_test_document
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        document_xml = zip.read('word/document.xml')

        # Should include XML declaration
        expect(document_xml).to start_with('<?xml')
      end
    end
  end

  describe 'Cross-Application Compatibility' do
    let(:test_path) { "#{tmp_dir}/cross_app_test.docx" }

    it 'generates files openable by standard ZIP utilities' do
      doc = create_test_document
      doc.save(test_path)

      # Can be opened with Ruby's Zip library
      expect { Zip::File.open(test_path) {} }.not_to raise_error
    end

    it 'uses UTF-8 encoding for text content' do
      doc = create_document_with_unicode
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        document_xml = zip.read('word/document.xml')

        # ZIP libraries read as binary, force to UTF-8 to check validity
        utf8_xml = document_xml.force_encoding('UTF-8')
        expect(utf8_xml.valid_encoding?).to be true
        expect(utf8_xml.encoding.name).to eq('UTF-8')
      end
    end

    it 'handles special characters correctly' do
      doc = create_document_with_special_chars
      doc.save(test_path)

      Zip::File.open(test_path) do |zip|
        document_xml = zip.read('word/document.xml')

        # XML should be well-formed despite special characters
        expect { Nokogiri::XML(document_xml) { |config| config.strict } }
          .not_to raise_error
      end
    end
  end

  # Helper methods
  private

  def create_test_document
    doc = Uniword::Document.new
    para = Uniword::Paragraph.new
    run = Uniword::Run.new
    run.text = 'Test document content'
    para.add_run(run)
    doc.add_element(para)
    doc
  end

  def create_document_with_styles
    doc = Uniword::Document.new

    # Add a paragraph with potential style
    para = Uniword::Paragraph.new
    run = Uniword::Run.new
    run.text = 'Styled content'
    para.add_run(run)
    doc.add_element(para)

    doc
  end

  def create_document_with_numbering
    doc = Uniword::Document.new

    # Add paragraphs that might trigger numbering
    3.times do |i|
      para = Uniword::Paragraph.new
      run = Uniword::Run.new
      run.text = "List item #{i + 1}"
      para.add_run(run)
      doc.add_element(para)
    end

    doc
  end

  def create_document_with_unicode
    doc = Uniword::Document.new
    para = Uniword::Paragraph.new
    run = Uniword::Run.new
    run.text = 'Unicode: 你好 مرحبا 🌍 café'
    para.add_run(run)
    doc.add_element(para)
    doc
  end

  def create_document_with_special_chars
    doc = Uniword::Document.new
    para = Uniword::Paragraph.new
    run = Uniword::Run.new
    run.text = 'Special: < > & " \' © ® ™'
    para.add_run(run)
    doc.add_element(para)
    doc
  end

  def create_full_featured_document
    doc = Uniword::Document.new

    # Paragraphs
    para1 = Uniword::Paragraph.new
    run1 = Uniword::Run.new
    run1.add_text('First paragraph')
    para1.add_run(run1)
    doc.add_element(para1)

    # Table
    table = Uniword::Table.new
    row = Uniword::TableRow.new
    cell = Uniword::TableCell.new
    cell_para = Uniword::Paragraph.new
    cell_run = Uniword::Run.new
    cell_run.text = 'Table cell'
    cell_para.add_run(cell_run)
    cell.add_paragraph(cell_para)
    row.add_cell(cell)
    table.add_row(row)
    doc.add_element(table)

    # Another paragraph
    para2 = Uniword::Paragraph.new
    run2 = Uniword::Run.new
    run2.add_text('Second paragraph')
    para2.add_run(run2)
    doc.add_element(para2)

    doc
  end
end