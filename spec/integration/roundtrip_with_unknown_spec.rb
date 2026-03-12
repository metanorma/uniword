# frozen_string_literal: true

require 'spec_helper'
require 'digest'

RSpec.describe 'Round-trip with Unknown Elements' do
  let(:deserializer) { Uniword::Serialization::OoxmlDeserializer.new }
  let(:serializer) { Uniword::Serialization::OoxmlSerializer.new }

  describe 'preserving chart elements' do
    let(:chart_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                    xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
                    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
          <w:body>
            <w:p>
              <w:r>
                <w:t>Text before chart</w:t>
              </w:r>
            </w:p>
            <c:chart>
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
            <w:p>
              <w:r>
                <w:t>Text after chart</w:t>
              </w:r>
            </w:p>
          </w:body>
        </w:document>
      XML
    end

    it 'preserves chart element through round-trip' do
      # Deserialize
      document = deserializer.deserialize(chart_xml)

      # Verify document structure
      expect(document.body.elements.count).to eq(3)
      expect(document.body.elements[0]).to be_a(Uniword::Paragraph)
      expect(document.body.elements[1]).to be_a(Uniword::UnknownElement)
      expect(document.body.elements[2]).to be_a(Uniword::Paragraph)

      # Verify unknown element
      unknown = document.body.elements[1]
      expect(unknown.tag_name).to eq('chart')
      expect(unknown.namespace).to include('drawingml/2006/chart')
      expect(unknown.element_type).to eq(:data)
      expect(unknown.to_xml).to include('<c:chart')
      expect(unknown.to_xml).to include('Sales Chart')
      expect(unknown.to_xml).to include('<c:barChart>')

      # Serialize
      output_xml = serializer.serialize(document)

      # Verify chart is preserved in output
      expect(output_xml).to include('<c:chart')
      expect(output_xml).to include('Sales Chart')
      expect(output_xml).to include('<c:barChart>')
      expect(output_xml).to include('<c:val>100</c:val>')
    end

    it 'records warning for chart element' do
      collector = Uniword::Warnings::WarningCollector.new
      deserializer_with_collector = Uniword::Serialization::OoxmlDeserializer.new(
        warning_collector: collector
      )

      deserializer_with_collector.deserialize(chart_xml)

      expect(collector.warnings.count).to eq(1)
      warning = collector.warnings.first
      expect(warning.element).to eq('chart')
      expect(warning.type).to eq(:unsupported_element)
      expect(warning.context).to eq('In document body')
    end
  end

  describe 'preserving SmartArt elements' do
    let(:smartart_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                    xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram"
                    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <w:body>
            <w:p>
              <w:r>
                <w:t>Document with SmartArt</w:t>
              </w:r>
            </w:p>
            <dgm:relIds r:dm="rId1" r:lo="rId2" r:qs="rId3" r:cs="rId4"/>
            <w:p>
              <w:r>
                <w:t>After SmartArt</w:t>
              </w:r>
            </w:p>
          </w:body>
        </w:document>
      XML
    end

    it 'preserves SmartArt element through round-trip' do
      document = deserializer.deserialize(smartart_xml)

      # Verify SmartArt preserved as unknown element
      expect(document.body.elements.count).to eq(3)
      unknown = document.body.elements[1]
      expect(unknown).to be_a(Uniword::UnknownElement)
      expect(unknown.tag_name).to eq('relIds')
      # relIds is a diagram-related element, but tag doesn't match our patterns
      expect(unknown.element_type).to eq(:unknown)

      # Verify round-trip
      output_xml = serializer.serialize(document)
      expect(output_xml).to include('<dgm:relIds')
      expect(output_xml).to include('r:dm="rId1"')
      expect(output_xml).to include('r:lo="rId2"')
    end
  end

  describe 'preserving content control (sdt) elements' do
    let(:sdt_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p>
              <w:r>
                <w:t>Before control</w:t>
              </w:r>
            </w:p>
            <w:sdt>
              <w:sdtPr>
                <w:alias w:val="MyControl"/>
                <w:tag w:val="Control1"/>
              </w:sdtPr>
              <w:sdtContent>
                <w:p>
                  <w:r>
                    <w:t>Control Content</w:t>
                  </w:r>
                </w:p>
              </w:sdtContent>
            </w:sdt>
            <w:p>
              <w:r>
                <w:t>After control</w:t>
              </w:r>
            </w:p>
          </w:body>
        </w:document>
      XML
    end

    it 'preserves content control as critical unknown element' do
      document = deserializer.deserialize(sdt_xml)

      # Verify sdt preserved
      expect(document.body.elements.count).to eq(3)
      unknown = document.body.elements[1]
      expect(unknown).to be_a(Uniword::UnknownElement)
      expect(unknown.tag_name).to eq('sdt')
      expect(unknown.element_type).to eq(:structure)
      expect(unknown.critical?).to be true

      # Verify round-trip
      output_xml = serializer.serialize(document)
      expect(output_xml).to include('<w:sdt>')
      expect(output_xml).to include('<w:sdtPr>')
      expect(output_xml).to include('w:val="MyControl"')
      expect(output_xml).to include('<w:sdtContent>')
      expect(output_xml).to include('Control Content')
    end

    it 'records warning for critical sdt element' do
      collector = Uniword::Warnings::WarningCollector.new
      deserializer_with_collector = Uniword::Serialization::OoxmlDeserializer.new(
        warning_collector: collector
      )

      deserializer_with_collector.deserialize(sdt_xml)

      expect(collector.warnings.count).to eq(1)
      warning = collector.warnings.first
      expect(warning.element).to eq('sdt')
    end
  end

  describe 'preserving multiple unknown elements' do
    let(:complex_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                    xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
                    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                    xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math">
          <w:body>
            <w:p>
              <w:r>
                <w:t>Introduction</w:t>
              </w:r>
            </w:p>
            <c:chart>
              <c:title><c:tx><c:rich><a:p>Chart 1</a:p></c:rich></c:tx></c:title>
            </c:chart>
            <w:p>
              <w:r>
                <w:t>Middle section</w:t>
              </w:r>
              <m:oMath>
                <m:r><m:t>x^2 + y^2 = z^2</m:t></m:r>
              </m:oMath>
            </w:p>
            <c:chart>
              <c:title><c:tx><c:rich><a:p>Chart 2</a:p></c:rich></c:tx></c:title>
            </c:chart>
            <w:p>
              <w:r>
                <w:t>Conclusion</w:t>
              </w:r>
            </w:p>
          </w:body>
        </w:document>
      XML
    end

    it 'preserves all unknown elements in correct order' do
      document = deserializer.deserialize(complex_xml)

      # Verify structure: 5 elements total
      expect(document.body.elements.count).to eq(5)

      # Check types in order
      expect(document.body.elements[0]).to be_a(Uniword::Paragraph) # Introduction
      expect(document.body.elements[1]).to be_a(Uniword::UnknownElement) # Chart 1
      expect(document.body.elements[2]).to be_a(Uniword::Paragraph) # Middle + math
      expect(document.body.elements[3]).to be_a(Uniword::UnknownElement) # Chart 2
      expect(document.body.elements[4]).to be_a(Uniword::Paragraph) # Conclusion

      # Verify unknown elements
      chart1 = document.body.elements[1]
      expect(chart1.tag_name).to eq('chart')
      expect(chart1.to_xml).to include('Chart 1')

      # Middle paragraph has unknown math element
      middle_para = document.body.elements[2]
      math_element = middle_para.runs.find { |r| r.is_a?(Uniword::UnknownElement) }
      expect(math_element).not_to be_nil
      expect(math_element.tag_name).to eq('oMath')
      expect(math_element.to_xml).to include('x^2 + y^2 = z^2')

      chart2 = document.body.elements[3]
      expect(chart2.tag_name).to eq('chart')
      expect(chart2.to_xml).to include('Chart 2')

      # Full round-trip
      output_xml = serializer.serialize(document)
      expect(output_xml).to include('Introduction')
      expect(output_xml).to include('Chart 1')
      expect(output_xml).to include('x^2 + y^2 = z^2')
      expect(output_xml).to include('Chart 2')
      expect(output_xml).to include('Conclusion')
    end

    it 'tracks multiple warnings correctly' do
      collector = Uniword::Warnings::WarningCollector.new
      deserializer_with_collector = Uniword::Serialization::OoxmlDeserializer.new(
        warning_collector: collector
      )

      deserializer_with_collector.deserialize(complex_xml)

      # Should have 3 warnings: 2 charts + 1 math
      expect(collector.warnings.count).to eq(3)

      # Check element counts
      expect(collector.element_counts['chart']).to eq(2)
      expect(collector.element_counts['oMath']).to eq(1)

      # Generate report
      report = collector.report
      expect(report.total_count).to eq(3)
    end
  end

  describe 'preserving unknown elements with known content' do
    let(:mixed_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:body>
            <w:p>
              <w:pPr>
                <w:pStyle w:val="Heading1"/>
              </w:pPr>
              <w:r>
                <w:rPr>
                  <w:b/>
                </w:rPr>
                <w:t>Title</w:t>
              </w:r>
            </w:p>
            <w:tbl>
              <w:tr>
                <w:tc>
                  <w:p>
                    <w:r>
                      <w:t>Cell content</w:t>
                    </w:r>
                  </w:p>
                </w:tc>
              </w:tr>
            </w:tbl>
          </w:body>
        </w:document>
      XML
    end

    it 'handles mix of known and unknown elements correctly' do
      document = deserializer.deserialize(mixed_xml)

      # Should parse known elements normally
      expect(document.body.elements.count).to eq(2)
      expect(document.body.elements[0]).to be_a(Uniword::Paragraph)
      expect(document.body.elements[1]).to be_a(Uniword::Table)

      # Paragraph should have proper properties
      para = document.body.elements[0]
      expect(para.properties).not_to be_nil
      expect(para.properties.style).to eq('Heading1')

      # Run should have bold formatting
      run = para.runs.first
      expect(run.properties).to be_bold
      expect(run.text).to eq('Title')

      # Table should be properly parsed
      table = document.body.elements[1]
      expect(table.rows.count).to eq(1)
      expect(table.rows[0].cells[0].paragraphs[0].runs[0].text).to eq('Cell content')

      # Round-trip should preserve everything
      output_xml = serializer.serialize(document)
      expect(output_xml).to include('<w:pStyle w:val="Heading1"/>')
      expect(output_xml).to include('<w:b/>')
      expect(output_xml).to include('Title')
      expect(output_xml).to include('Cell content')
    end

    it 'does not generate warnings for known elements' do
      collector = Uniword::Warnings::WarningCollector.new
      deserializer_with_collector = Uniword::Serialization::OoxmlDeserializer.new(
        warning_collector: collector
      )

      deserializer_with_collector.deserialize(mixed_xml)

      # No warnings - all elements are known
      expect(collector.warnings.count).to eq(0)
    end
  end

  describe 'exact byte preservation for complex elements' do
    let(:complex_chart_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                    xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
                    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
          <w:body>
            <c:chart>
              <c:title>
                <c:tx>
                  <c:rich>
                    <a:bodyPr/>
                    <a:lstStyle/>
                    <a:p>
                      <a:pPr>
                        <a:defRPr sz="1400" b="1"/>
                      </a:pPr>
                      <a:r>
                        <a:rPr lang="en-US" sz="1400" b="1"/>
                        <a:t>Sales by Quarter</a:t>
                      </a:r>
                    </a:p>
                  </c:rich>
                </c:tx>
              </c:title>
              <c:plotArea>
                <c:layout/>
                <c:barChart>
                  <c:barDir val="col"/>
                  <c:grouping val="clustered"/>
                  <c:ser>
                    <c:idx val="0"/>
                    <c:order val="0"/>
                    <c:tx>
                      <c:strRef>
                        <c:f>Sheet1!$B$1</c:f>
                      </c:strRef>
                    </c:tx>
                    <c:val>
                      <c:numRef>
                        <c:f>Sheet1!$B$2:$B$5</c:f>
                      </c:numRef>
                    </c:val>
                  </c:ser>
                </c:barChart>
              </c:plotArea>
            </c:chart>
          </w:body>
        </w:document>
      XML
    end

    it 'preserves complex nested chart XML exactly' do
      document = deserializer.deserialize(complex_chart_xml)

      unknown = document.body.elements[0]
      expect(unknown).to be_a(Uniword::UnknownElement)

      # Verify all nested elements are preserved
      xml = unknown.to_xml
      expect(xml).to include('<c:chart>')
      expect(xml).to include('<c:title>')
      expect(xml).to include('<c:rich>')
      expect(xml).to include('<a:bodyPr/>')
      expect(xml).to include('<a:lstStyle/>')
      expect(xml).to include('Sales by Quarter')
      expect(xml).to include('<c:plotArea>')
      expect(xml).to include('<c:barChart>')
      expect(xml).to include('<c:barDir val="col"/>')
      expect(xml).to include('<c:grouping val="clustered"/>')
      expect(xml).to include('Sheet1!$B$1')
      expect(xml).to include('Sheet1!$B$2:$B$5')

      # Round-trip preserves everything
      output_xml = serializer.serialize(document)
      expect(output_xml).to include('Sales by Quarter')
      expect(output_xml).to include('Sheet1!$B$1')
      expect(output_xml).to include('<c:barDir val="col"/>')
    end
  end

  describe 'warning report generation' do
    let(:document_with_unknowns) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                    xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart">
          <w:body>
            <w:p><w:r><w:t>Para 1</w:t></w:r></w:p>
            <c:chart><c:title><c:tx>Chart 1</c:tx></c:title></c:chart>
            <w:p><w:r><w:t>Para 2</w:t></w:r></w:p>
            <c:chart><c:title><c:tx>Chart 2</c:tx></c:title></c:chart>
            <w:p><w:r><w:t>Para 3</w:t></w:r></w:p>
            <c:chart><c:title><c:tx>Chart 3</c:tx></c:title></c:chart>
          </w:body>
        </w:document>
      XML
    end

    it 'generates comprehensive warning report' do
      collector = Uniword::Warnings::WarningCollector.new
      deserializer_with_collector = Uniword::Serialization::OoxmlDeserializer.new(
        warning_collector: collector
      )

      document = deserializer_with_collector.deserialize(document_with_unknowns)

      # Verify warnings collected
      expect(collector.warnings.count).to eq(3)
      expect(collector.element_counts['chart']).to eq(3)

      # Generate report
      report = collector.report
      expect(report.total_count).to eq(3)

      # Document preserved correctly
      expect(document.body.elements.count).to eq(6) # 3 paras + 3 charts
    end
  end
end
