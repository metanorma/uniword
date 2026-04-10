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
      # Create a document with a chart using the Builder API
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph { |p| p << 'Document with chart' }
      doc.chart(type: :bar) do |c|
        c.title 'Sales Report'
        c.categories %w[Q1 Q2 Q3 Q4]
        c.series 'Revenue', data: [100, 200, 150, 300]
      end

      # Save document
      doc.model.to_file(temp_file.path)

      # Load it back via DocxPackage
      package = Uniword::Ooxml::DocxPackage.from_file(temp_file.path)

      # Verify chart was preserved in chart_parts
      expect(package.document.chart_parts).not_to be_nil
      expect(package.document.chart_parts).not_to be_empty

      chart_data = package.document.chart_parts.values.first
      expect(chart_data[:xml]).to include('Sales Report')
      expect(chart_data[:target]).to match(%r{charts/chart\d+\.xml})
    end

    it 'preserves multiple charts' do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph { |p| p << 'Two charts here' }
      doc.chart(type: :bar) do |c|
        c.title 'Chart 1'
        c.categories %w[A B]
        c.series 'Series1', data: [1, 2]
      end
      doc.chart(type: :line) do |c|
        c.title 'Chart 2'
        c.categories %w[X Y]
        c.series 'Series2', data: [10, 20]
      end

      doc.model.to_file(temp_file.path)
      package = Uniword::Ooxml::DocxPackage.from_file(temp_file.path)

      expect(package.document.chart_parts.size).to eq(2)
      chart_targets = package.document.chart_parts.values.map { |c| c[:target] }
      expect(chart_targets).to include('charts/chart1.xml', 'charts/chart2.xml')
    end

    it 'handles documents without charts' do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph { |p| p << 'No charts here' }

      doc.model.to_file(temp_file.path)
      package = Uniword::Ooxml::DocxPackage.from_file(temp_file.path)

      expect(package.document.chart_parts.nil? || package.document.chart_parts.empty?).to be(true)
    end

    it 'validates chart properties from XML' do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph { |p| p << 'Chart test' }
      doc.chart(type: :pie) do |c|
        c.title 'Pie Chart'
        c.categories %w[Alpha Beta Gamma]
        c.series 'Share', data: [45, 30, 25]
      end

      doc.model.to_file(temp_file.path)
      package = Uniword::Ooxml::DocxPackage.from_file(temp_file.path)

      chart_data = package.document.chart_parts.values.first
      expect(chart_data[:xml]).to include('Pie Chart')
      expect(chart_data[:xml]).to include('<c:pieChart')
    end

    it 'preserves chart metadata through round-trip' do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph { |p| p << 'Data chart' }
      doc.chart(type: :bar) do |c|
        c.title 'Data Points'
        c.categories %w[Jan Feb Mar]
        c.series 'Series 1', data: [1, 2, 3]
        c.series 'Series 2', data: [4, 5, 6]
      end

      doc.model.to_file(temp_file.path)
      package = Uniword::Ooxml::DocxPackage.from_file(temp_file.path)

      chart_data = package.document.chart_parts.values.first
      expect(chart_data[:xml]).to include('Data Points')
      expect(chart_data[:xml]).to include('Series 1')
      expect(chart_data[:xml]).to include('Series 2')
    end
  end

  describe 'chart type detection' do
    it 'detects bar charts' do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph { |p| p << 'Bar chart' }
      doc.chart(type: :bar) do |c|
        c.title 'Bar Test'
        c.categories %w[1 2]
        c.series 'Data', data: [10, 20]
      end

      doc.model.to_file(temp_file.path)
      package = Uniword::Ooxml::DocxPackage.from_file(temp_file.path)

      chart_data = package.document.chart_parts.values.first
      expect(chart_data[:xml]).to include('<c:barChart')
    end

    it 'detects line charts' do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph { |p| p << 'Line chart' }
      doc.chart(type: :line) do |c|
        c.title 'Line Test'
        c.categories %w[1 2]
        c.series 'Data', data: [10, 20]
      end

      doc.model.to_file(temp_file.path)
      package = Uniword::Ooxml::DocxPackage.from_file(temp_file.path)

      chart_data = package.document.chart_parts.values.first
      expect(chart_data[:xml]).to include('<c:lineChart')
    end

    it 'detects pie charts' do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.paragraph { |p| p << 'Pie chart' }
      doc.chart(type: :pie) do |c|
        c.title 'Pie Test'
        c.categories %w[A B]
        c.series 'Data', data: [30, 70]
      end

      doc.model.to_file(temp_file.path)
      package = Uniword::Ooxml::DocxPackage.from_file(temp_file.path)

      chart_data = package.document.chart_parts.values.first
      expect(chart_data[:xml]).to include('<c:pieChart')
    end
  end
end
