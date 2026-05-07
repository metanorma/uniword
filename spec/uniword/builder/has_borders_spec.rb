# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::HasBorders do
  # Use ParagraphBuilder as a concrete host for testing
  let(:builder) { Uniword::Builder::ParagraphBuilder.new }

  describe "#borders" do
    it "sets borders with color strings" do
      builder.borders(top: "FF0000", bottom: "00FF00")
      borders = builder.model.properties.borders
      expect(borders.top.color).to eq("FF0000")
      expect(borders.bottom.color).to eq("00FF00")
    end

    it "sets borders with hash options" do
      builder.borders(
        left: { color: "0000FF", style: "double", size: 8 },
        right: { color: "CCCCCC", style: "dashed", size: 2 },
      )
      borders = builder.model.properties.borders
      expect(borders.left.color).to eq("0000FF")
      expect(borders.left.style).to eq("double")
      expect(borders.left.size).to eq(8)
      expect(borders.right.style).to eq("dashed")
    end

    it "defaults to single style and size 4 for color-only values" do
      builder.borders(top: "FF0000")
      border = builder.model.properties.borders.top
      expect(border.style).to eq("single")
      expect(border.size).to eq(4)
    end

    it "returns self for chaining" do
      result = builder.borders(top: "FF0000")
      expect(result).to eq(builder)
    end

    it "works with TableBuilder" do
      tbl = Uniword::Builder::TableBuilder.new
      tbl.borders(top: "000000", bottom: "000000")
      expect(tbl.model.properties.borders.top.color).to eq("000000")
    end

    it "works with TableCellBuilder" do
      cell = Uniword::Builder::TableCellBuilder.new
      cell.borders(left: "AAAAAA", right: "BBBBBB")
      expect(cell.model.properties.borders.left.color).to eq("AAAAAA")
      expect(cell.model.properties.borders.right.color).to eq("BBBBBB")
    end
  end
end
