# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Chart do
  let(:basic_attributes) do
    {
      chart_type: 'bar',
      title: 'Sales by Quarter',
      relationship_id: 'rId5'
    }
  end

  let(:full_attributes) do
    {
      chart_type: 'line',
      title: 'Revenue Trend',
      relationship_id: 'rId10',
      part_path: 'charts/chart1.xml',
      series: [
        { name: 'Q1', values: [100, 200, 300] },
        { name: 'Q2', values: [150, 250, 350] }
      ],
      axes: [
        { type: 'cat', position: 'b', id: 1 },
        { type: 'val', position: 'l', id: 2 }
      ],
      legend: { position: 'r' },
      vary_colors: true
    }
  end

  describe '#initialize' do
    it 'creates chart with basic attributes' do
      chart = described_class.new(basic_attributes)

      expect(chart.chart_type).to eq('bar')
      expect(chart.title).to eq('Sales by Quarter')
      expect(chart.relationship_id).to eq('rId5')
    end

    it 'creates chart with full attributes' do
      chart = described_class.new(full_attributes)

      expect(chart.chart_type).to eq('line')
      expect(chart.title).to eq('Revenue Trend')
      expect(chart.relationship_id).to eq('rId10')
      expect(chart.part_path).to eq('charts/chart1.xml')
      expect(chart.series.length).to eq(2)
      expect(chart.axes.length).to eq(2)
      expect(chart.legend).to eq({ position: 'r' })
      expect(chart.vary_colors).to be true
    end

    it 'initializes with empty series by default' do
      chart = described_class.new(basic_attributes)

      expect(chart.series).to eq([])
    end

    it 'initializes with empty axes by default' do
      chart = described_class.new(basic_attributes)

      expect(chart.axes).to eq([])
    end

    it 'initializes vary_colors to false by default' do
      chart = described_class.new(basic_attributes)

      expect(chart.vary_colors).to be false
    end
  end

  describe '#valid?' do
    it 'returns true for valid chart' do
      chart = described_class.new(basic_attributes)

      expect(chart).to be_valid
    end

    it 'returns false when relationship_id is nil' do
      attributes = basic_attributes.dup
      attributes[:relationship_id] = nil
      chart = described_class.new(attributes)

      expect(chart).not_to be_valid
    end

    it 'returns false when relationship_id is empty' do
      attributes = basic_attributes.dup
      attributes[:relationship_id] = ''
      chart = described_class.new(attributes)

      expect(chart).not_to be_valid
    end

    it 'returns false when chart_type is nil' do
      attributes = basic_attributes.dup
      attributes[:chart_type] = nil
      chart = described_class.new(attributes)

      expect(chart).not_to be_valid
    end

    it 'returns false when chart_type is empty' do
      attributes = basic_attributes.dup
      attributes[:chart_type] = ''
      chart = described_class.new(attributes)

      expect(chart).not_to be_valid
    end
  end

  describe '#category' do
    it 'returns :bar for bar charts' do
      chart = described_class.new(chart_type: 'bar', relationship_id: 'rId1')
      expect(chart.category).to eq(:bar)
    end

    it 'returns :bar for barChart' do
      chart = described_class.new(chart_type: 'barChart', relationship_id: 'rId1')
      expect(chart.category).to eq(:bar)
    end

    it 'returns :line for line charts' do
      chart = described_class.new(chart_type: 'line', relationship_id: 'rId1')
      expect(chart.category).to eq(:line)
    end

    it 'returns :pie for pie charts' do
      chart = described_class.new(chart_type: 'pie', relationship_id: 'rId1')
      expect(chart.category).to eq(:pie)
    end

    it 'returns :pie for doughnut charts' do
      chart = described_class.new(chart_type: 'doughnut', relationship_id: 'rId1')
      expect(chart.category).to eq(:pie)
    end

    it 'returns :scatter for scatter charts' do
      chart = described_class.new(chart_type: 'scatter', relationship_id: 'rId1')
      expect(chart.category).to eq(:scatter)
    end

    it 'returns :area for area charts' do
      chart = described_class.new(chart_type: 'area', relationship_id: 'rId1')
      expect(chart.category).to eq(:area)
    end

    it 'returns :radar for radar charts' do
      chart = described_class.new(chart_type: 'radar', relationship_id: 'rId1')
      expect(chart.category).to eq(:radar)
    end

    it 'returns :stock for stock charts' do
      chart = described_class.new(chart_type: 'stock', relationship_id: 'rId1')
      expect(chart.category).to eq(:stock)
    end

    it 'returns :bubble for bubble charts' do
      chart = described_class.new(chart_type: 'bubble', relationship_id: 'rId1')
      expect(chart.category).to eq(:bubble)
    end

    it 'returns :surface for surface charts' do
      chart = described_class.new(chart_type: 'surface', relationship_id: 'rId1')
      expect(chart.category).to eq(:surface)
    end

    it 'returns :other for unknown types' do
      chart = described_class.new(chart_type: 'unknown', relationship_id: 'rId1')
      expect(chart.category).to eq(:other)
    end
  end

  describe '#has_data?' do
    it 'returns true when chart has series' do
      chart = described_class.new(full_attributes)

      expect(chart.has_data?).to be true
    end

    it 'returns false when chart has no series' do
      chart = described_class.new(basic_attributes)

      expect(chart.has_data?).to be false
    end
  end

  describe '#series_count' do
    it 'returns number of series' do
      chart = described_class.new(full_attributes)

      expect(chart.series_count).to eq(2)
    end

    it 'returns 0 when no series' do
      chart = described_class.new(basic_attributes)

      expect(chart.series_count).to eq(0)
    end
  end

  describe '#point_count' do
    it 'returns number of points in first series' do
      chart = described_class.new(full_attributes)

      expect(chart.point_count).to eq(3)
    end

    it 'returns nil when no series' do
      chart = described_class.new(basic_attributes)

      expect(chart.point_count).to be_nil
    end

    it 'returns nil when first series has no values' do
      attributes = basic_attributes.merge(series: [{ name: 'Test' }])
      chart = described_class.new(attributes)

      expect(chart.point_count).to be_nil
    end
  end

  describe '#has_title?' do
    it 'returns true when title is present' do
      chart = described_class.new(basic_attributes)

      expect(chart.has_title?).to be true
    end

    it 'returns false when title is nil' do
      attributes = basic_attributes.dup
      attributes.delete(:title)
      chart = described_class.new(attributes)

      expect(chart.has_title?).to be false
    end

    it 'returns false when title is empty' do
      attributes = basic_attributes.merge(title: '')
      chart = described_class.new(attributes)

      expect(chart.has_title?).to be false
    end
  end

  describe '#has_legend?' do
    it 'returns true when legend is present' do
      chart = described_class.new(full_attributes)

      expect(chart.has_legend?).to be true
    end

    it 'returns false when legend is nil' do
      chart = described_class.new(basic_attributes)

      expect(chart.has_legend?).to be false
    end

    it 'returns false when legend is empty hash' do
      attributes = basic_attributes.merge(legend: {})
      chart = described_class.new(attributes)

      expect(chart.has_legend?).to be false
    end
  end

  describe '#legend_position' do
    it 'returns legend position with symbol key' do
      chart = described_class.new(full_attributes)

      expect(chart.legend_position).to eq('r')
    end

    it 'returns legend position with string key' do
      attributes = full_attributes.dup
      attributes[:legend] = { 'position' => 'b' }
      chart = described_class.new(attributes)

      expect(chart.legend_position).to eq('b')
    end

    it 'returns nil when legend is nil' do
      chart = described_class.new(basic_attributes)

      expect(chart.legend_position).to be_nil
    end

    it 'returns nil when legend has no position' do
      attributes = basic_attributes.merge(legend: { other: 'data' })
      chart = described_class.new(attributes)

      expect(chart.legend_position).to be_nil
    end
  end

  describe '#add_series' do
    it 'adds a series to the chart' do
      chart = described_class.new(basic_attributes)
      series_data = { name: 'Q3', values: [200, 300, 400] }

      chart.add_series(series_data)

      expect(chart.series_count).to eq(1)
      expect(chart.series.first).to eq(series_data)
    end

    it 'adds multiple series' do
      chart = described_class.new(basic_attributes)

      chart.add_series({ name: 'Q1', values: [100] })
      chart.add_series({ name: 'Q2', values: [200] })

      expect(chart.series_count).to eq(2)
    end
  end

  describe '#add_axis' do
    it 'adds an axis to the chart' do
      chart = described_class.new(basic_attributes)
      axis_data = { type: 'cat', position: 'b', id: 1 }

      chart.add_axis(axis_data)

      expect(chart.axes.length).to eq(1)
      expect(chart.axes.first).to eq(axis_data)
    end

    it 'adds multiple axes' do
      chart = described_class.new(basic_attributes)

      chart.add_axis({ type: 'cat', position: 'b', id: 1 })
      chart.add_axis({ type: 'val', position: 'l', id: 2 })

      expect(chart.axes.length).to eq(2)
    end
  end

  describe '#to_h' do
    it 'returns hash representation' do
      chart = described_class.new(full_attributes)
      hash = chart.to_h

      expect(hash[:chart_type]).to eq('line')
      expect(hash[:title]).to eq('Revenue Trend')
      expect(hash[:relationship_id]).to eq('rId10')
      expect(hash[:part_path]).to eq('charts/chart1.xml')
      expect(hash[:series_count]).to eq(2)
      expect(hash[:has_legend]).to be true
      expect(hash[:legend_position]).to eq('r')
      expect(hash[:category]).to eq(:line)
    end

    it 'compacts nil values' do
      chart = described_class.new(basic_attributes)
      hash = chart.to_h

      expect(hash).not_to have_key(:part_path)
      expect(hash).not_to have_key(:legend_position)
    end
  end

  describe '#to_s' do
    it 'returns string representation with title' do
      chart = described_class.new(full_attributes)

      expect(chart.to_s).to eq("Chart(line 'Revenue Trend', 2 series)")
    end

    it 'returns string representation without title' do
      attributes = basic_attributes.dup
      attributes.delete(:title)
      chart = described_class.new(attributes)

      expect(chart.to_s).to eq('Chart(bar, 0 series)')
    end
  end

  describe '#inspect' do
    it 'returns detailed description' do
      chart = described_class.new(full_attributes)
      inspection = chart.inspect

      expect(inspection).to include('Uniword::Chart')
      expect(inspection).to include('@chart_type="line"')
      expect(inspection).to include('@title="Revenue Trend"')
      expect(inspection).to include('@relationship_id="rId10"')
      expect(inspection).to include('@series_count=2')
      expect(inspection).to include('@has_legend=true')
    end
  end

  describe '#accept' do
    it 'calls visit_chart on visitor' do
      chart = described_class.new(basic_attributes)
      visitor = double('visitor')

      expect(visitor).to receive(:visit_chart).with(chart)

      chart.accept(visitor)
    end

    it 'does nothing if visitor does not respond to visit_chart' do
      chart = described_class.new(basic_attributes)
      visitor = double('visitor')

      expect { chart.accept(visitor) }.not_to raise_error
    end
  end

  describe 'inheritance' do
    it 'inherits from Element' do
      expect(described_class.superclass).to eq(Uniword::Element)
    end

    it 'is registered in ElementRegistry' do
      # Element registration happens via inherited hook
      expect(Uniword::ElementRegistry.registered_classes).to include(described_class)
    end
  end
end