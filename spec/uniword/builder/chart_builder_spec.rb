# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::ChartBuilder do
  describe "#build_xml" do
    it "builds bar chart XML with series and categories" do
      cb = described_class.new(chart_type: :bar)
      cb.title "Sales"
      cb.categories ["Q1", "Q2"]
      cb.series "Revenue", data: [100, 200]
      xml = cb.build_xml

      expect(xml).to include("barChart")
      expect(xml).to include("<a:t>Sales</a:t>")
      expect(xml).to include("<c:v>Revenue</c:v>")
      expect(xml).to include("<c:v>Q1</c:v>")
      expect(xml).to include("<c:v>200</c:v>")
      expect(xml).to include("barDir")
      expect(xml).to include("clustered")
    end

    it "builds line chart XML" do
      cb = described_class.new(chart_type: :line)
      cb.series "Trend", data: [1, 2, 3]
      xml = cb.build_xml

      expect(xml).to include("lineChart")
      expect(xml).to include("standard")
      expect(xml).to include("<c:v>Trend</c:v>")
    end

    it "builds pie chart XML" do
      cb = described_class.new(chart_type: :pie)
      cb.series "Share", data: [45, 30, 25]
      xml = cb.build_xml

      expect(xml).to include("pieChart")
      expect(xml).to include("<c:v>Share</c:v>")
    end

    it "does not include axes for pie charts" do
      cb = described_class.new(chart_type: :pie)
      cb.series "Data", data: [10]
      xml = cb.build_xml

      expect(xml).not_to include("catAx")
      expect(xml).not_to include("valAx")
    end

    it "includes axes for bar and line charts" do
      cb = described_class.new(chart_type: :bar)
      cb.series "Data", data: [10]
      xml = cb.build_xml

      expect(xml).to include("catAx")
      expect(xml).to include("valAx")
    end

    it "builds multiple series" do
      cb = described_class.new(chart_type: :bar)
      cb.categories ["A", "B"]
      cb.series "S1", data: [1, 2]
      cb.series "S2", data: [3, 4]
      xml = cb.build_xml

      expect(xml).to include("<c:v>S1</c:v>")
      expect(xml).to include("<c:v>S2</c:v>")
      expect(xml.scan("<c:ser").length).to eq(2)
    end
  end

  describe "#dimensions" do
    it "sets chart width and height" do
      cb = described_class.new
      cb.dimensions(width: 1_000_000, height: 500_000)
      expect(cb.build_drawing(Uniword::Builder::DocumentBuilder.new))
        .to be_a(Uniword::Wordprocessingml::Drawing)
    end
  end
end
