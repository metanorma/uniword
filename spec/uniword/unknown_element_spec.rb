# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/uniword/unknown_element'
require_relative '../../lib/uniword/warnings/warning_collector'

RSpec.describe Uniword::UnknownElement do
  describe '#initialize' do
    it 'creates unknown element with required parameters' do
      element = described_class.new(
        tag_name: 'chart',
        raw_xml: '<c:chart xmlns:c="http://example.com">...</c:chart>'
      )

      expect(element.tag_name).to eq('chart')
      expect(element.raw_xml).to eq('<c:chart xmlns:c="http://example.com">...</c:chart>')
      expect(element.namespace).to be_nil
      expect(element.context).to be_nil
      expect(element.critical?).to be false
    end

    it 'creates unknown element with all parameters' do
      element = described_class.new(
        tag_name: 'smartArt',
        raw_xml: '<dgm:relIds>...</dgm:relIds>',
        namespace: 'http://schemas.openxmlformats.org/drawingml/2006/diagram',
        context: 'In paragraph 5',
        critical: true
      )

      expect(element.tag_name).to eq('smartArt')
      expect(element.raw_xml).to eq('<dgm:relIds>...</dgm:relIds>')
      expect(element.namespace).to eq('http://schemas.openxmlformats.org/drawingml/2006/diagram')
      expect(element.context).to eq('In paragraph 5')
      expect(element.critical?).to be true
    end

    it 'raises error when tag_name is nil' do
      expect do
        described_class.new(
          tag_name: nil,
          raw_xml: '<chart>...</chart>'
        )
      end.to raise_error(ArgumentError, /tag_name cannot be nil or empty/)
    end

    it 'raises error when tag_name is empty' do
      expect do
        described_class.new(
          tag_name: '   ',
          raw_xml: '<chart>...</chart>'
        )
      end.to raise_error(ArgumentError, /tag_name cannot be nil or empty/)
    end

    it 'raises error when raw_xml is nil' do
      expect do
        described_class.new(
          tag_name: 'chart',
          raw_xml: nil
        )
      end.to raise_error(ArgumentError, /raw_xml cannot be nil or empty/)
    end

    it 'raises error when raw_xml is empty' do
      expect do
        described_class.new(
          tag_name: 'chart',
          raw_xml: '   '
        )
      end.to raise_error(ArgumentError, /raw_xml cannot be nil or empty/)
    end

    it 'records warning when warning_collector provided' do
      collector = Uniword::Warnings::WarningCollector.new

      described_class.new(
        tag_name: 'chart',
        raw_xml: '<chart>...</chart>',
        context: 'Test context',
        warning_collector: collector
      )

      expect(collector.warnings.count).to eq(1)
      warning = collector.warnings.first
      expect(warning.element).to eq('chart')
      expect(warning.type).to eq(:unsupported_element)
    end

    it 'handles warning_collector that does not respond to record_unsupported' do
      fake_collector = double('FakeCollector')

      # Should not raise error
      expect do
        described_class.new(
          tag_name: 'chart',
          raw_xml: '<chart>...</chart>',
          warning_collector: fake_collector
        )
      end.not_to raise_error
    end
  end

  describe '#to_xml' do
    it 'returns raw XML unchanged' do
      raw = '<c:chart xmlns:c="http://example.com"><c:data>test</c:data></c:chart>'
      element = described_class.new(
        tag_name: 'chart',
        raw_xml: raw
      )

      expect(element.to_xml).to eq(raw)
    end

    it 'preserves complex XML structure exactly' do
      raw = <<~XML
        <c:chart xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart">
          <c:title>
            <c:tx>
              <c:rich>
                <a:p>Sales Chart</a:p>
              </c:rich>
            </c:tx>
          </c:title>
          <c:plotArea>
            <c:barChart>
              <c:ser>
                <c:val>100</c:val>
              </c:ser>
            </c:barChart>
          </c:plotArea>
        </c:chart>
      XML

      element = described_class.new(
        tag_name: 'chart',
        raw_xml: raw
      )

      expect(element.to_xml).to eq(raw)
    end

    it 'preserves whitespace in raw XML' do
      raw = "  <chart>  \n  <data>  test  </data>  \n  </chart>  "
      element = described_class.new(
        tag_name: 'chart',
        raw_xml: raw
      )

      expect(element.to_xml).to eq(raw)
    end
  end

  describe '#critical?' do
    it 'returns false by default' do
      element = described_class.new(
        tag_name: 'chart',
        raw_xml: '<chart>...</chart>'
      )

      expect(element.critical?).to be false
    end

    it 'returns true when marked as critical' do
      element = described_class.new(
        tag_name: 'sdt',
        raw_xml: '<sdt>...</sdt>',
        critical: true
      )

      expect(element.critical?).to be true
    end
  end

  describe '#element_type' do
    it 'classifies chart as data element' do
      element = described_class.new(
        tag_name: 'chart',
        raw_xml: '<chart>...</chart>'
      )

      expect(element.element_type).to eq(:data)
    end

    it 'classifies diagram as data element' do
      element = described_class.new(
        tag_name: 'diagram',
        raw_xml: '<diagram>...</diagram>'
      )

      expect(element.element_type).to eq(:data)
    end

    it 'classifies smartArt as data element' do
      element = described_class.new(
        tag_name: 'smartArt',
        raw_xml: '<smartArt>...</smartArt>'
      )

      expect(element.element_type).to eq(:data)
    end

    it 'classifies math as data element' do
      element = described_class.new(
        tag_name: 'mathElement',
        raw_xml: '<math>...</math>'
      )

      expect(element.element_type).to eq(:data)
    end

    it 'classifies sdt as structure element' do
      element = described_class.new(
        tag_name: 'sdt',
        raw_xml: '<sdt>...</sdt>'
      )

      expect(element.element_type).to eq(:structure)
    end

    it 'classifies control as structure element' do
      element = described_class.new(
        tag_name: 'contentControl',
        raw_xml: '<control>...</control>'
      )

      expect(element.element_type).to eq(:structure)
    end

    it 'classifies section as structure element' do
      element = described_class.new(
        tag_name: 'sectPr',
        raw_xml: '<section>...</section>'
      )

      expect(element.element_type).to eq(:structure)
    end

    it 'classifies style as formatting element' do
      element = described_class.new(
        tag_name: 'advancedStyle',
        raw_xml: '<style>...</style>'
      )

      expect(element.element_type).to eq(:formatting)
    end

    it 'classifies effect as formatting element' do
      element = described_class.new(
        tag_name: 'textEffect',
        raw_xml: '<effect>...</effect>'
      )

      expect(element.element_type).to eq(:formatting)
    end

    it 'classifies property as metadata element' do
      element = described_class.new(
        tag_name: 'customProperty',
        raw_xml: '<property>...</property>'
      )

      expect(element.element_type).to eq(:metadata)
    end

    it 'classifies unknown tag as unknown type' do
      element = described_class.new(
        tag_name: 'customElement',
        raw_xml: '<custom>...</custom>'
      )

      expect(element.element_type).to eq(:unknown)
    end

    it 'is case-insensitive' do
      element = described_class.new(
        tag_name: 'CHART',
        raw_xml: '<CHART>...</CHART>'
      )

      expect(element.element_type).to eq(:data)
    end
  end

  describe '#to_h' do
    it 'returns hash with all attributes' do
      element = described_class.new(
        tag_name: 'chart',
        raw_xml: '<chart>...</chart>',
        namespace: 'http://example.com',
        context: 'In paragraph 5',
        critical: true
      )

      hash = element.to_h
      expect(hash[:tag_name]).to eq('chart')
      expect(hash[:namespace]).to eq('http://example.com')
      expect(hash[:context]).to eq('In paragraph 5')
      expect(hash[:critical]).to be true
      expect(hash[:element_type]).to eq(:data)
      expect(hash[:xml_length]).to eq('<chart>...</chart>'.length)
    end

    it 'returns hash without nil values' do
      element = described_class.new(
        tag_name: 'chart',
        raw_xml: '<chart>...</chart>'
      )

      hash = element.to_h
      expect(hash).not_to have_key(:namespace)
      expect(hash).not_to have_key(:context)
    end
  end

  describe '#to_s' do
    it 'returns readable string' do
      element = described_class.new(
        tag_name: 'chart',
        raw_xml: '<chart>...</chart>'
      )

      expect(element.to_s).to eq('UnknownElement: chart')
    end

    it 'includes namespace when present' do
      element = described_class.new(
        tag_name: 'chart',
        raw_xml: '<chart>...</chart>',
        namespace: 'http://example.com'
      )

      expect(element.to_s).to eq('UnknownElement: chart [http://example.com]')
    end

    it 'marks critical elements' do
      element = described_class.new(
        tag_name: 'sdt',
        raw_xml: '<sdt>...</sdt>',
        critical: true
      )

      expect(element.to_s).to eq('UnknownElement: sdt (CRITICAL)')
    end

    it 'includes both namespace and critical marker' do
      element = described_class.new(
        tag_name: 'sdt',
        raw_xml: '<sdt>...</sdt>',
        namespace: 'http://example.com',
        critical: true
      )

      expect(element.to_s).to eq('UnknownElement: sdt [http://example.com] (CRITICAL)')
    end
  end

  describe '#inspect' do
    it 'returns detailed inspection string' do
      element = described_class.new(
        tag_name: 'chart',
        raw_xml: '<chart>data</chart>',
        namespace: 'http://example.com',
        critical: false
      )

      inspection = element.inspect
      expect(inspection).to include('UnknownElement')
      expect(inspection).to include('@tag_name="chart"')
      expect(inspection).to include('@namespace="http://example.com"')
      expect(inspection).to include('@critical=false')
      expect(inspection).to include('@xml_length=')
      expect(inspection).to include('@xml_preview=')
    end

    it 'truncates long XML in preview' do
      long_xml = '<chart>' + ('x' * 200) + '</chart>'
      element = described_class.new(
        tag_name: 'chart',
        raw_xml: long_xml
      )

      inspection = element.inspect
      expect(inspection).to include('...')
      expect(inspection.length).to be < long_xml.length
    end

    it 'does not truncate short XML' do
      short_xml = '<chart>test</chart>'
      element = described_class.new(
        tag_name: 'chart',
        raw_xml: short_xml
      )

      inspection = element.inspect
      expect(inspection).to include(short_xml)
      expect(inspection).not_to include('...')
    end
  end

  describe 'integration with real OOXML' do
    it 'preserves chart element' do
      chart_xml = <<~XML
        <c:chart xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <c:title>
            <c:tx>
              <c:strRef>
                <c:f>Sheet1!$B$1</c:f>
              </c:strRef>
            </c:tx>
          </c:title>
        </c:chart>
      XML

      element = described_class.new(
        tag_name: 'chart',
        raw_xml: chart_xml,
        namespace: 'http://schemas.openxmlformats.org/drawingml/2006/chart',
        context: 'In paragraph'
      )

      # Verify preservation
      expect(element.to_xml).to eq(chart_xml)
      expect(element.element_type).to eq(:data)
    end

    it 'preserves SmartArt element' do
      smartart_xml = <<~XML
        <dgm:relIds xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:dm="rId1" r:lo="rId2" r:qs="rId3" r:cs="rId4"/>
      XML

      element = described_class.new(
        tag_name: 'smartArt',
        raw_xml: smartart_xml,
        namespace: 'http://schemas.openxmlformats.org/drawingml/2006/diagram'
      )

      expect(element.to_xml).to eq(smartart_xml)
      expect(element.element_type).to eq(:data)
    end

    it 'preserves content control element' do
      sdt_xml = <<~XML
        <w:sdt xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:sdtPr>
            <w:alias w:val="MyControl"/>
            <w:tag w:val="Control1"/>
          </w:sdtPr>
          <w:sdtContent>
            <w:p>
              <w:r>
                <w:t>Content</w:t>
              </w:r>
            </w:p>
          </w:sdtContent>
        </w:sdt>
      XML

      element = described_class.new(
        tag_name: 'sdt',
        raw_xml: sdt_xml,
        namespace: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
        critical: true
      )

      expect(element.to_xml).to eq(sdt_xml)
      expect(element.element_type).to eq(:structure)
      expect(element.critical?).to be true
    end
  end
end