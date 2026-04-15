# frozen_string_literal: true

require "spec_helper"

# v2.0 API: Uniword::Chart is a module, not a class
# Chart classes are in the Uniword::Chart namespace:
# - Uniword::Chart::ChartSpace (root element for chart documents)
# - Uniword::Chart::Chart (chart container)
# - Uniword::Chart::BarChart, LineChart, etc. (chart types)

RSpec.describe "Uniword::Chart module" do
  describe "Uniword::Chart" do
    it "is a module, not a class" do
      expect(Uniword::Chart).to be_a(Module)
    end

    it "contains Chart class" do
      expect(Uniword::Chart::Chart).to be_a(Class)
    end

    it "contains ChartSpace class" do
      expect(Uniword::Chart::ChartSpace).to be_a(Class)
    end

    it "contains chart type classes" do
      expect(Uniword::Chart::BarChart).to be_a(Class)
      expect(Uniword::Chart::LineChart).to be_a(Class)
      expect(Uniword::Chart::PieChart).to be_a(Class)
    end
  end

  describe Uniword::Chart::Chart do
    it "inherits from Lutaml::Model::Serializable" do
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end

    it "does not inherit from Element (v2.0 uses direct lutaml-model inheritance)" do
      expect(described_class.ancestors).not_to include(Uniword::Element)
    end

    describe "#initialize" do
      it "creates chart with title" do
        title = Uniword::Chart::Title.new
        chart = described_class.new(title: title)
        expect(chart.title).to eq(title)
      end

      it "creates chart with plot_area" do
        plot_area = Uniword::Chart::PlotArea.new
        chart = described_class.new(plot_area: plot_area)
        expect(chart.plot_area).to eq(plot_area)
      end

      it "creates chart with legend" do
        legend = Uniword::Chart::Legend.new
        chart = described_class.new(legend: legend)
        expect(chart.legend).to eq(legend)
      end
    end
  end

  describe Uniword::Chart::ChartSpace do
    it "inherits from Lutaml::Model::Serializable" do
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end

    describe "#initialize" do
      it "creates chart space with chart" do
        chart = Uniword::Chart::Chart.new
        chart_space = described_class.new(chart: chart)
        expect(chart_space.chart).to eq(chart)
      end
    end
  end

  describe Uniword::Chart::BarChart do
    it "inherits from Lutaml::Model::Serializable" do
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end
  end

  describe Uniword::Chart::LineChart do
    it "inherits from Lutaml::Model::Serializable" do
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end
  end

  describe Uniword::Chart::PieChart do
    it "inherits from Lutaml::Model::Serializable" do
      expect(described_class.ancestors).to include(Lutaml::Model::Serializable)
    end
  end
end
