# frozen_string_literal: true

require "spec_helper"
require "uniword/wordprocessingml"

RSpec.describe Uniword::Wordprocessingml::PageDefaults do
  describe ".default_page_size" do
    it "returns a PageSize with US Letter dimensions" do
      ps = described_class.default_page_size

      expect(ps).to be_a(Uniword::Wordprocessingml::PageSize)
      expect(ps.width).to eq(12_240)
      expect(ps.height).to eq(15_840)
    end
  end

  describe ".default_page_margins" do
    it "returns PageMargins with standard 1-inch margins" do
      pm = described_class.default_page_margins

      expect(pm).to be_a(Uniword::Wordprocessingml::PageMargins)
      expect(pm.top).to eq(1440)
      expect(pm.bottom).to eq(1440)
      expect(pm.left).to eq(1440)
      expect(pm.right).to eq(1440)
    end

    it "includes header and footer margins" do
      pm = described_class.default_page_margins

      expect(pm.header).to eq(720)
      expect(pm.footer).to eq(720)
      expect(pm.gutter).to eq(0)
    end
  end

  describe ".default_columns" do
    it "returns Columns with default spacing" do
      cols = described_class.default_columns

      expect(cols).to be_a(Uniword::Wordprocessingml::Columns)
      expect(cols.space).to eq(720)
    end
  end

  describe ".default_doc_grid" do
    it "returns DocGrid with standard line pitch" do
      grid = described_class.default_doc_grid

      expect(grid).to be_a(Uniword::Wordprocessingml::DocGrid)
      expect(grid.line_pitch).to eq(360)
    end
  end

  describe "constants" do
    it "exposes LETTER_WIDTH and LETTER_HEIGHT" do
      expect(described_class::LETTER_WIDTH).to eq(12_240)
      expect(described_class::LETTER_HEIGHT).to eq(15_840)
    end
  end
end
