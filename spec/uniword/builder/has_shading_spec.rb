# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::HasShading do
  describe "#shading" do
    it "sets shading with fill only" do
      builder = Uniword::Builder::ParagraphBuilder.new
      builder.shading(fill: "FF0000")
      shading = builder.model.properties.shading
      expect(shading.fill).to eq("FF0000")
      expect(shading.pattern).to eq("clear")
    end

    it "sets shading with all options" do
      builder = Uniword::Builder::ParagraphBuilder.new
      builder.shading(fill: "00FF00", color: "000000", pattern: "diagonalCross")
      shading = builder.model.properties.shading
      expect(shading.fill).to eq("00FF00")
      expect(shading.color).to eq("000000")
      expect(shading.pattern).to eq("diagonalCross")
    end

    it "returns self for chaining" do
      builder = Uniword::Builder::ParagraphBuilder.new
      result = builder.shading(fill: "FF0000")
      expect(result).to eq(builder)
    end

    it "works with RunBuilder" do
      run = Uniword::Builder::RunBuilder.new
      run.shading(fill: "FFFF00", pattern: "horzStripe")
      shading = run.model.properties.shading
      expect(shading.fill).to eq("FFFF00")
      expect(shading.pattern).to eq("horzStripe")
    end

    it "works with TableBuilder" do
      tbl = Uniword::Builder::TableBuilder.new
      tbl.shading(fill: "4472C4")
      expect(tbl.model.properties.shading.fill).to eq("4472C4")
    end

    it "works with TableCellBuilder" do
      cell = Uniword::Builder::TableCellBuilder.new
      cell.shading(fill: "CCCCCC")
      expect(cell.model.properties.shading.fill).to eq("CCCCCC")
    end
  end
end
