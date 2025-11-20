# frozen_string_literal: true

require 'spec_helper'
require 'canon/rspec_matchers'

RSpec.describe Uniword::Ooxml::AppProperties do
  describe 'initialization' do
    it 'creates a new instance with sensible defaults' do
      props = described_class.new

      expect(props).to be_a(described_class)
      expect(props.template).to eq('Normal.dotm')
      expect(props.application).to eq('Uniword')
      expect(props.app_version).to eq('16.0000')
      expect(props.total_time).to eq('0')
      expect(props.scale_crop).to eq('false')
    end

    it 'accepts attributes on initialization' do
      props = described_class.new(
        application: 'TestApp',
        company: 'Acme Corp',
        pages: '10',
        words: '1000',
        characters: '5000'
      )

      expect(props.application).to eq('TestApp')
      expect(props.company).to eq('Acme Corp')
      expect(props.pages).to eq('10')
      expect(props.words).to eq('1000')
      expect(props.characters).to eq('5000')
    end
  end

  describe 'XML serialization' do
    it 'generates valid XML with proper namespaces' do
      props = described_class.new(
        application: 'Uniword',
        company: 'Test Company',
        pages: '5',
        words: '500'
      )

      xml = props.to_xml

      expected = <<~XML
        <app:Properties xmlns:app="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">
          <app:Application>Uniword</app:Application>
          <app:Company>Test Company</app:Company>
          <app:Pages>5</app:Pages>
          <app:Words>500</app:Words>
        </app:Properties>
      XML

      expect(xml).to be_xml_equivalent_to(expected)
    end

    it 'includes all default values when explicitly set' do
      props = described_class.new(
        template: 'Normal.dotm',
        application: 'Uniword',
        total_time: '0'
      )

      xml = props.to_xml

      expected = <<~XML
        <app:Properties xmlns:app="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">
          <app:Template>Normal.dotm</app:Template>
          <app:Application>Uniword</app:Application>
          <app:TotalTime>0</app:TotalTime>
        </app:Properties>
      XML

      expect(xml).to be_xml_equivalent_to(expected)
    end

    it 'serializes all document statistics' do
      props = described_class.new(
        pages: '100',
        words: '10000',
        characters: '50000',
        lines: '2000',
        paragraphs: '500',
        characters_with_spaces: '60000'
      )

      xml = props.to_xml

      expected = <<~XML
        <app:Properties xmlns:app="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">
          <app:Pages>100</app:Pages>
          <app:Words>10000</app:Words>
          <app:Characters>50000</app:Characters>
          <app:Lines>2000</app:Lines>
          <app:Paragraphs>500</app:Paragraphs>
          <app:CharactersWithSpaces>60000</app:CharactersWithSpaces>
        </app:Properties>
      XML

      expect(xml).to be_xml_equivalent_to(expected)
    end
  end

  describe 'XML deserialization' do
    it 'parses valid OOXML app properties XML' do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <Properties
          xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
          xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
          <Template>Normal.dotm</Template>
          <Application>Microsoft Office Word</Application>
          <Company>Test Corporation</Company>
          <Pages>25</Pages>
          <Words>5000</Words>
          <Characters>25000</Characters>
          <Lines>500</Lines>
          <Paragraphs>100</Paragraphs>
          <CharactersWithSpaces>30000</CharactersWithSpaces>
          <TotalTime>120</TotalTime>
          <ScaleCrop>false</ScaleCrop>
          <DocSecurity>0</DocSecurity>
          <LinksUpToDate>false</LinksUpToDate>
          <SharedDoc>false</SharedDoc>
          <HyperlinksChanged>false</HyperlinksChanged>
          <AppVersion>16.0000</AppVersion>
        </Properties>
      XML

      props = described_class.from_xml(xml)

      expect(props.template).to eq('Normal.dotm')
      expect(props.application).to eq('Microsoft Office Word')
      expect(props.company).to eq('Test Corporation')
      expect(props.pages).to eq('25')
      expect(props.words).to eq('5000')
      expect(props.characters).to eq('25000')
      expect(props.lines).to eq('500')
      expect(props.paragraphs).to eq('100')
      expect(props.characters_with_spaces).to eq('30000')
      expect(props.total_time).to eq('120')
      expect(props.app_version).to eq('16.0000')
    end

    it 'handles minimal XML correctly' do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <Properties
          xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">
          <Application>Uniword</Application>
        </Properties>
      XML

      props = described_class.from_xml(xml)

      expect(props.application).to eq('Uniword')
      expect(props.company).to be_nil
      expect(props.pages).to be_nil
    end
  end

  describe 'round-trip fidelity' do
    it 'preserves all data through serialize/deserialize cycle' do
      original = described_class.new(
        template: 'Custom.dotx',
        application: 'Uniword Test',
        company: 'Test Corp',
        app_version: '16.0000',
        pages: '50',
        words: '10000',
        characters: '50000',
        lines: '1000',
        paragraphs: '200',
        characters_with_spaces: '60000',
        total_time: '240',
        scale_crop: 'false',
        doc_security: '0',
        links_up_to_date: 'false',
        shared_doc: 'false',
        hyperlinks_changed: 'false'
      )

      xml = original.to_xml
      restored = described_class.from_xml(xml)

      expect(restored.template).to eq(original.template)
      expect(restored.application).to eq(original.application)
      expect(restored.company).to eq(original.company)
      expect(restored.app_version).to eq(original.app_version)
      expect(restored.pages).to eq(original.pages)
      expect(restored.words).to eq(original.words)
      expect(restored.characters).to eq(original.characters)
      expect(restored.lines).to eq(original.lines)
      expect(restored.paragraphs).to eq(original.paragraphs)
      expect(restored.characters_with_spaces).to eq(original.characters_with_spaces)
      expect(restored.total_time).to eq(original.total_time)
    end

    it 'handles default values consistently' do
      original = described_class.new

      xml = original.to_xml
      restored = described_class.from_xml(xml)

      # Default values should be preserved
      expect(restored.application).to eq('Uniword')
    end
  end

  describe 'integration with Document' do
    it 'can be used as Document app_properties' do
      doc = Uniword::Document.new

      expect(doc.app_properties).to be_a(described_class)
      expect(doc.app_properties.application).to eq('Uniword')
    end

    it 'auto-populates statistics during serialization' do
      doc = Uniword::Document.new
      doc.add_paragraph('Test paragraph one')
      doc.add_paragraph('Test paragraph two')

      # Serializer should auto-populate these
      expect(doc.app_properties).to be_a(described_class)
    end
  end
end