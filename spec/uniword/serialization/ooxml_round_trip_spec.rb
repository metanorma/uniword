# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'OOXML Round-trip Serialization' do
  let(:serializer) { Uniword::Serialization::OoxmlSerializer.new }
  let(:deserializer) { Uniword::Serialization::OoxmlDeserializer.new }

  describe 'simple document round-trip' do
    it 'preserves empty document structure' do
      # Create empty document
      original = Uniword::Document.new

      # Serialize to XML
      xml = serializer.serialize(original)

      # Deserialize back
      restored = deserializer.deserialize(xml)

      # Verify structure
      expect(restored).to be_a(Uniword::Document)
      expect(restored.body).to be_a(Uniword::Body)
      expect(restored.body.paragraphs).to be_empty
    end

    it 'preserves document with single paragraph' do
      # Create document with one paragraph
      original = Uniword::Document.new
      paragraph = Uniword::Paragraph.new
      run = Uniword::Run.new(text: 'Hello World')
      paragraph.add_run(run)
      original.add_element(paragraph)

      # Serialize to XML
      xml = serializer.serialize(original)

      # Deserialize back
      restored = deserializer.deserialize(xml)

      # Verify content
      expect(restored.paragraphs.size).to eq(1)
      expect(restored.paragraphs.first.text).to eq('Hello World')
    end

    it 'preserves document with multiple paragraphs' do
      # Create document with multiple paragraphs
      original = Uniword::Document.new

      # First paragraph
      p1 = Uniword::Paragraph.new
      p1.add_run(Uniword::Run.new(text: 'First paragraph'))
      original.add_element(p1)

      # Second paragraph
      p2 = Uniword::Paragraph.new
      p2.add_run(Uniword::Run.new(text: 'Second paragraph'))
      original.add_element(p2)

      # Serialize and deserialize
      xml = serializer.serialize(original)
      restored = deserializer.deserialize(xml)

      # Verify content
      expect(restored.paragraphs.size).to eq(2)
      expect(restored.paragraphs[0].text).to eq('First paragraph')
      expect(restored.paragraphs[1].text).to eq('Second paragraph')
    end
  end

  describe 'paragraph with multiple runs' do
    it 'preserves multiple runs in a paragraph' do
      original = Uniword::Document.new
      paragraph = Uniword::Paragraph.new

      # Add multiple runs
      paragraph.add_run(Uniword::Run.new(text: 'Hello '))
      paragraph.add_run(Uniword::Run.new(text: 'World'))
      original.add_element(paragraph)

      # Serialize and deserialize
      xml = serializer.serialize(original)
      restored = deserializer.deserialize(xml)

      # Verify runs
      expect(restored.paragraphs.first.runs.size).to eq(2)
      expect(restored.paragraphs.first.runs[0].text).to eq('Hello ')
      expect(restored.paragraphs.first.runs[1].text).to eq('World')
      expect(restored.paragraphs.first.text).to eq('Hello World')
    end
  end

  describe 'run properties preservation' do
    it 'preserves bold formatting' do
      original = Uniword::Document.new
      paragraph = Uniword::Paragraph.new
      props = Uniword::Properties::RunProperties.new(bold: true)
      run = Uniword::Run.new(text: 'Bold text', properties: props)
      paragraph.add_run(run)
      original.add_element(paragraph)

      # Serialize and deserialize
      xml = serializer.serialize(original)
      restored = deserializer.deserialize(xml)

      # Verify properties
      restored_run = restored.paragraphs.first.runs.first
      expect(restored_run.text).to eq('Bold text')
      expect(restored_run.bold?).to be true
    end

    it 'preserves italic formatting' do
      original = Uniword::Document.new
      paragraph = Uniword::Paragraph.new
      props = Uniword::Properties::RunProperties.new(italic: true)
      run = Uniword::Run.new(text: 'Italic text', properties: props)
      paragraph.add_run(run)
      original.add_element(paragraph)

      # Serialize and deserialize
      xml = serializer.serialize(original)
      restored = deserializer.deserialize(xml)

      # Verify properties
      restored_run = restored.paragraphs.first.runs.first
      expect(restored_run.text).to eq('Italic text')
      expect(restored_run.italic?).to be true
    end

    it 'preserves multiple formatting properties' do
      original = Uniword::Document.new
      paragraph = Uniword::Paragraph.new
      props = Uniword::Properties::RunProperties.new(
        bold: true,
        italic: true,
        underline: 'single',
        size: 24,
        color: 'FF0000'
      )
      run = Uniword::Run.new(text: 'Formatted text', properties: props)
      paragraph.add_run(run)
      original.add_element(paragraph)

      # Serialize and deserialize
      xml = serializer.serialize(original)
      restored = deserializer.deserialize(xml)

      # Verify all properties
      restored_run = restored.paragraphs.first.runs.first
      expect(restored_run.text).to eq('Formatted text')
      expect(restored_run.bold?).to be true
      expect(restored_run.italic?).to be true
      expect(restored_run.underline?).to be true
      expect(restored_run.properties.size).to eq(24)
      expect(restored_run.properties.color).to eq('FF0000')
    end
  end

  describe 'paragraph properties preservation' do
    it 'preserves paragraph alignment' do
      original = Uniword::Document.new
      props = Uniword::Properties::ParagraphProperties.new(
        alignment: 'center'
      )
      paragraph = Uniword::Paragraph.new(properties: props)
      paragraph.add_run(Uniword::Run.new(text: 'Centered text'))
      original.add_element(paragraph)

      # Serialize and deserialize
      xml = serializer.serialize(original)
      restored = deserializer.deserialize(xml)

      # Verify properties
      restored_para = restored.paragraphs.first
      expect(restored_para.alignment).to eq('center')
    end

    it 'preserves paragraph style' do
      original = Uniword::Document.new
      props = Uniword::Properties::ParagraphProperties.new(
        style: 'Heading1'
      )
      paragraph = Uniword::Paragraph.new(properties: props)
      paragraph.add_run(Uniword::Run.new(text: 'Heading text'))
      original.add_element(paragraph)

      # Serialize and deserialize
      xml = serializer.serialize(original)
      restored = deserializer.deserialize(xml)

      # Verify properties
      restored_para = restored.paragraphs.first
      expect(restored_para.style).to eq('Heading1')
    end
  end

  describe 'XML structure validation' do
    it 'generates valid OOXML with proper namespaces' do
      original = Uniword::Document.new
      paragraph = Uniword::Paragraph.new
      paragraph.add_run(Uniword::Run.new(text: 'Test'))
      original.add_element(paragraph)

      xml = serializer.serialize(original)

      # Verify XML structure
      doc = Nokogiri::XML(xml)
      expect(doc.errors).to be_empty

      # Verify namespaces
      expect(xml).to include('xmlns:w=')
      expect(xml).to include('http://schemas.openxmlformats.org/wordprocessingml/2006/main')
    end

    it 'generates properly nested elements' do
      original = Uniword::Document.new
      paragraph = Uniword::Paragraph.new
      paragraph.add_run(Uniword::Run.new(text: 'Test'))
      original.add_element(paragraph)

      xml = serializer.serialize(original)

      # Parse and verify structure
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath('//w:document',
                          'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')).not_to be_nil
      expect(doc.at_xpath('//w:body',
                          'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')).not_to be_nil
      expect(doc.at_xpath('//w:p',
                          'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')).not_to be_nil
      expect(doc.at_xpath('//w:r',
                          'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')).not_to be_nil
      expect(doc.at_xpath('//w:t',
                          'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')).not_to be_nil
    end
  end

  describe 'error handling' do
    it 'raises error for nil document' do
      expect { serializer.serialize(nil) }.to raise_error(ArgumentError, /cannot be nil/)
    end

    it 'raises error for invalid document type' do
      expect { serializer.serialize('not a document') }.to raise_error(ArgumentError, /must be a Uniword::Document/)
    end

    it 'raises error for nil content' do
      expect { deserializer.deserialize(nil) }.to raise_error(ArgumentError, /cannot be nil/)
    end

    it 'raises error for empty content' do
      expect { deserializer.deserialize('') }.to raise_error(ArgumentError, /cannot be empty/)
    end

    it 'raises error for invalid XML' do
      expect do
        deserializer.deserialize('<invalid>')
      end.to raise_error(ArgumentError, /Failed to deserialize/)
    end
  end
end
