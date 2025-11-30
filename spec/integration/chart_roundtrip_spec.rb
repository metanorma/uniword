# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Chart Round-trip Integration' do
  let(:temp_file) { Tempfile.new(['chart_test', '.docx']) }

  after do
    temp_file.close
    temp_file.unlink
  end

  describe 'chart preservation' do
    it 'preserves charts through round-trip' do
      # Create a document with a chart
      doc = Uniword::Document.new

      chart = Uniword::Chart.new(
        chart_type: 'bar',
        title: 'Sales Report',
        relationship_id: 'rId5',
        part_path: 'charts/chart1.xml',
        chart_data: { raw_xml: minimal_chart_xml }
      )

      doc.add_chart(chart)

      # Add a paragraph
      para = Uniword::Paragraph.new
      para.add_text('Document with chart')
      doc.add_element(para)

      # Save document
      doc.save(temp_file.path)

      # Read it back
      loaded_doc = Uniword::Document.open(temp_file.path)

      # Verify chart was preserved
      expect(loaded_doc.charts).not_to be_empty
      expect(loaded_doc.charts.length).to eq(1)

      loaded_chart = loaded_doc.charts.first
      expect(loaded_chart.chart_type).to eq('bar')
      expect(loaded_chart.title).to eq('Sales Report')
      expect(loaded_chart.part_path).to match(%r{charts/chart\d+\.xml})
    end

    it 'preserves multiple charts' do
      doc = Uniword::Document.new

      # Add two charts
      chart1 = Uniword::Chart.new(
        chart_type: 'bar',
        title: 'Chart 1',
        relationship_id: 'rId5',
        chart_data: { raw_xml: minimal_chart_xml }
      )

      chart2 = Uniword::Chart.new(
        chart_type: 'line',
        title: 'Chart 2',
        relationship_id: 'rId6',
        chart_data: { raw_xml: minimal_line_chart_xml }
      )

      doc.add_chart(chart1)
      doc.add_chart(chart2)

      # Save and reload
      doc.save(temp_file.path)
      loaded_doc = Uniword::Document.open(temp_file.path)

      # Verify both charts preserved
      expect(loaded_doc.charts.length).to eq(2)
      expect(loaded_doc.charts.map(&:chart_type)).to contain_exactly('bar', 'line')
      expect(loaded_doc.charts.map(&:title)).to contain_exactly('Chart 1', 'Chart 2')
    end

    it 'handles documents without charts' do
      doc = Uniword::Document.new
      para = Uniword::Paragraph.new
      para.add_text('No charts here')
      doc.add_element(para)

      doc.save(temp_file.path)
      loaded_doc = Uniword::Document.open(temp_file.path)

      expect(loaded_doc.charts).to be_empty
    end

    it 'validates chart properties' do
      chart = Uniword::Chart.new(
        chart_type: 'pie',
        title: 'Pie Chart',
        relationship_id: 'rId7'
      )

      expect(chart).to be_valid
      expect(chart.category).to eq(:pie)
      expect(chart.has_title?).to be true
    end

    it 'preserves chart metadata through round-trip' do
      doc = Uniword::Document.new

      chart = Uniword::Chart.new(
        chart_type: 'scatter',
        title: 'Data Points',
        relationship_id: 'rId8',
        series: [
          { name: 'Series 1', values: [1, 2, 3] },
          { name: 'Series 2', values: [4, 5, 6] }
        ],
        legend: { position: 'r' },
        vary_colors: true,
        chart_data: { raw_xml: minimal_scatter_chart_xml }
      )

      doc.add_chart(chart)
      doc.save(temp_file.path)

      loaded_doc = Uniword::Document.open(temp_file.path)
      loaded_chart = loaded_doc.charts.first

      expect(loaded_chart.chart_type).to eq('scatter')
      expect(loaded_chart.title).to eq('Data Points')
      expect(loaded_chart.category).to eq(:scatter)
    end
  end

  describe 'chart type detection' do
    it 'detects bar charts' do
      doc = create_doc_with_chart(minimal_chart_xml)
      doc.save(temp_file.path)

      loaded_doc = Uniword::Document.open(temp_file.path)
      expect(loaded_doc.charts.first.chart_type).to eq('bar')
    end

    it 'detects line charts' do
      doc = create_doc_with_chart(minimal_line_chart_xml)
      doc.save(temp_file.path)

      loaded_doc = Uniword::Document.open(temp_file.path)
      expect(loaded_doc.charts.first.chart_type).to eq('line')
    end

    it 'detects pie charts' do
      doc = create_doc_with_chart(minimal_pie_chart_xml)
      doc.save(temp_file.path)

      loaded_doc = Uniword::Document.open(temp_file.path)
      expect(loaded_doc.charts.first.chart_type).to eq('pie')
    end
  end

  private

  def create_doc_with_chart(chart_xml)
    doc = Uniword::Document.new
    chart = Uniword::Chart.new(
      chart_type: 'unknown',
      title: 'Test Chart',
      relationship_id: 'rId5',
      chart_data: { raw_xml: chart_xml }
    )
    doc.add_chart(chart)
    doc
  end

  def minimal_chart_xml
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <c:chartSpace xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart">
        <c:chart>
          <c:title>
            <c:tx>
              <c:strRef>
                <c:f></c:f>
                <c:strCache>
                  <c:ptCount val="1"/>
                  <c:pt idx="0">
                    <c:v>Sales Report</c:v>
                  </c:pt>
                </c:strCache>
              </c:strRef>
            </c:tx>
          </c:title>
          <c:plotArea>
            <c:barChart>
              <c:barDir val="col"/>
            </c:barChart>
          </c:plotArea>
        </c:chart>
      </c:chartSpace>
    XML
  end

  def minimal_line_chart_xml
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <c:chartSpace xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart">
        <c:chart>
          <c:title>
            <c:tx>
              <c:strRef>
                <c:f></c:f>
                <c:strCache>
                  <c:ptCount val="1"/>
                  <c:pt idx="0">
                    <c:v>Chart 2</c:v>
                  </c:pt>
                </c:strCache>
              </c:strRef>
            </c:tx>
          </c:title>
          <c:plotArea>
            <c:lineChart>
              <c:grouping val="standard"/>
            </c:lineChart>
          </c:plotArea>
        </c:chart>
      </c:chartSpace>
    XML
  end

  def minimal_pie_chart_xml
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <c:chartSpace xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart">
        <c:chart>
          <c:plotArea>
            <c:pieChart>
              <c:varyColors val="1"/>
            </c:pieChart>
          </c:plotArea>
        </c:chart>
      </c:chartSpace>
    XML
  end

  def minimal_scatter_chart_xml
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <c:chartSpace xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart">
        <c:chart>
          <c:title>
            <c:tx>
              <c:strRef>
                <c:f></c:f>
                <c:strCache>
                  <c:ptCount val="1"/>
                  <c:pt idx="0">
                    <c:v>Data Points</c:v>
                  </c:pt>
                </c:strCache>
              </c:strRef>
            </c:tx>
          </c:title>
          <c:plotArea>
            <c:scatterChart>
              <c:scatterStyle val="lineMarker"/>
            </c:scatterChart>
          </c:plotArea>
        </c:chart>
      </c:chartSpace>
    XML
  end
end
