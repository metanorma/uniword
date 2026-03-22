# frozen_string_literal: true

require 'spec_helper'
require 'canon/rspec_matchers'

RSpec.describe Uniword::Ooxml::CoreProperties do
  describe 'initialization' do
    it 'creates a new instance with default timestamps' do
      props = described_class.new

      expect(props).to be_a(described_class)
      expect(props.created).not_to be_nil
      expect(props.modified).not_to be_nil
    end

    it 'accepts attributes on initialization' do
      props = described_class.new(
        title: 'Test Document',
        creator: 'John Doe',
        subject: 'Testing',
        keywords: 'test, rspec',
        description: 'A test document'
      )

      expect(props.title).to eq('Test Document')
      expect(props.creator).to eq('John Doe')
      expect(props.subject).to eq('Testing')
      expect(props.keywords).to eq('test, rspec')
      expect(props.description).to eq('A test document')
    end
  end

  describe 'XML serialization' do
    it 'generates valid XML with proper namespaces' do
      props = described_class.new(
        title: 'Test Document',
        creator: 'John Doe',
        subject: 'Test Subject',
        created: Uniword::Ooxml::Types::DctermsCreatedType.new(value: '2024-01-01T00:00:00Z', type: 'dcterms:W3CDTF'),
        modified: Uniword::Ooxml::Types::DctermsModifiedType.new(value: '2024-01-02T00:00:00Z', type: 'dcterms:W3CDTF')
      )

      xml = props.to_xml

      expected = <<~XML
        <cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
                          xmlns:dc="http://purl.org/dc/elements/1.1/"
                          xmlns:dcterms="http://purl.org/dc/terms/">
          <dc:title>Test Document</dc:title>
          <dc:subject>Test Subject</dc:subject>
          <dc:creator>John Doe</dc:creator>
          <dcterms:created>2024-01-01T00:00:00Z</dcterms:created>
          <dcterms:modified>2024-01-02T00:00:00Z</dcterms:modified>
        </cp:coreProperties>
      XML

      expect(xml).to be_xml_equivalent_to(expected)
    end

    it 'serializes all metadata fields' do
      props = described_class.new(
        title: 'Complete Test',
        subject: 'Testing All Fields',
        creator: 'Test Author',
        keywords: 'complete, test, metadata',
        description: 'Testing all available fields',
        last_modified_by: 'Test Editor',
        revision: '5',
        created: Uniword::Ooxml::Types::DctermsCreatedType.new(value: '2024-01-01T00:00:00Z', type: 'dcterms:W3CDTF'),
        modified: Uniword::Ooxml::Types::DctermsModifiedType.new(value: '2024-01-15T12:30:00Z', type: 'dcterms:W3CDTF')
      )

      xml = props.to_xml

      expected = <<~XML
        <cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
                          xmlns:dc="http://purl.org/dc/elements/1.1/"
                          xmlns:dcterms="http://purl.org/dc/terms/">
          <dc:title>Complete Test</dc:title>
          <dc:subject>Testing All Fields</dc:subject>
          <dc:creator>Test Author</dc:creator>
          <cp:keywords>complete, test, metadata</cp:keywords>
          <cp:description>Testing all available fields</cp:description>
          <cp:lastModifiedBy>Test Editor</cp:lastModifiedBy>
          <cp:revision>5</cp:revision>
          <dcterms:created>2024-01-01T00:00:00Z</dcterms:created>
          <dcterms:modified>2024-01-15T12:30:00Z</dcterms:modified>
        </cp:coreProperties>
      XML

      expect(xml).to be_xml_equivalent_to(expected)
    end

    it 'handles empty values correctly' do
      props = described_class.new(
        title: 'Test Document',
        creator: '',
        subject: nil
      )

      xml = props.to_xml

      # At minimum, title should be present
      expect(xml).to include('Test Document')
    end
  end

  describe 'XML deserialization' do
    it 'parses valid OOXML core properties XML' do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <cp:coreProperties
          xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
          xmlns:dc="http://purl.org/dc/elements/1.1/"
          xmlns:dcterms="http://purl.org/dc/terms/"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <dc:title>Round Trip Test</dc:title>
          <dc:creator>Test Author</dc:creator>
          <dc:subject>Test Subject</dc:subject>
          <cp:keywords>test, round-trip</cp:keywords>
          <dc:description>Testing deserialization</dc:description>
          <cp:lastModifiedBy>Test Editor</cp:lastModifiedBy>
          <cp:revision>1</cp:revision>
          <dcterms:created xsi:type="dcterms:W3CDTF">2024-01-01T00:00:00Z</dcterms:created>
          <dcterms:modified xsi:type="dcterms:W3CDTF">2024-01-01T00:00:00Z</dcterms:modified>
        </cp:coreProperties>
      XML

      props = described_class.from_xml(xml)

      expect(props.title).to eq('Round Trip Test')
      expect(props.creator).to eq('Test Author')
      expect(props.subject).to eq('Test Subject')
      expect(props.keywords).to eq('test, round-trip')
      expect(props.description).to eq('Testing deserialization')
      expect(props.last_modified_by).to eq('Test Editor')
      expect(props.revision).to eq('1')
      expect(props.created&.value).to eq('2024-01-01T00:00:00Z')
      expect(props.modified&.value).to eq('2024-01-01T00:00:00Z')
    end

    it 'handles minimal XML correctly' do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <cp:coreProperties
          xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
          xmlns:dc="http://purl.org/dc/elements/1.1/"
          xmlns:dcterms="http://purl.org/dc/terms/">
          <dc:title>Minimal Document</dc:title>
          <dc:creator>Author</dc:creator>
        </cp:coreProperties>
      XML

      props = described_class.from_xml(xml)

      expect(props.title).to eq('Minimal Document')
      expect(props.creator).to eq('Author')
      expect(props.subject).to be_nil
      expect(props.keywords).to be_nil
    end
  end

  describe 'round-trip fidelity' do
    it 'preserves all data through serialize/deserialize cycle' do
      original = described_class.new(
        title: 'Round Trip Test',
        subject: 'Testing Round Trip',
        creator: 'Test Author',
        keywords: 'test, round-trip, fidelity',
        description: 'Testing perfect round-trip preservation',
        last_modified_by: 'Test Editor',
        revision: '3',
        created: Uniword::Ooxml::Types::DctermsCreatedType.new(value: '2024-01-01T00:00:00Z', type: 'dcterms:W3CDTF'),
        modified: Uniword::Ooxml::Types::DctermsModifiedType.new(value: '2024-01-15T12:00:00Z', type: 'dcterms:W3CDTF')
      )

      xml = original.to_xml
      restored = described_class.from_xml(xml)

      expect(restored.title).to eq(original.title)
      expect(restored.subject).to eq(original.subject)
      expect(restored.creator).to eq(original.creator)
      expect(restored.keywords).to eq(original.keywords)
      expect(restored.description).to eq(original.description)
      expect(restored.last_modified_by).to eq(original.last_modified_by)
      expect(restored.revision).to eq(original.revision)
      expect(restored.created&.value).to eq(original.created&.value)
      expect(restored.modified&.value).to eq(original.modified&.value)
    end

    it 'handles empty strings consistently' do
      original = described_class.new(
        title: 'Test',
        creator: '',
        subject: nil
      )

      xml = original.to_xml
      restored = described_class.from_xml(xml)

      expect(restored.title).to eq(original.title)
    end
  end

  describe 'integration with Document' do
    it 'can be used as Document core_properties' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new

      expect(doc.core_properties).to be_a(described_class)
      expect(doc.core_properties.created).not_to be_nil
    end

    it 'updates when document title is set' do
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      doc.title = 'Integration Test'

      expect(doc.core_properties.title).to eq('Integration Test')
    end
  end
end
