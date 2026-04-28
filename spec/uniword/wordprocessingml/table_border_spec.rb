# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::TableBorder do
  describe "#initialize" do
    it "creates border with default values" do
      border = described_class.new
      expect(border.style).to eq("single")
      expect(border.width).to eq(4)
      expect(border.color).to eq("auto")
      expect(border.space).to eq(0)
    end

    it "creates border with custom values" do
      border = described_class.new(
        style: "double",
        width: 8,
        color: "FF0000",
        space: 2,
      )
      expect(border.style).to eq("double")
      expect(border.width).to eq(8)
      expect(border.color).to eq("FF0000")
      expect(border.space).to eq(2)
    end

    it "raises error for invalid style" do
      expect do
        described_class.new(style: "invalid")
      end.to raise_error(ArgumentError, /Invalid border style/)
    end
  end

  describe ".single" do
    it "creates single border with defaults" do
      border = described_class.single
      expect(border.style).to eq("single")
      expect(border.width).to eq(4)
      expect(border.color).to eq("auto")
    end

    it "accepts custom width and color" do
      border = described_class.single(width: 6, color: "0000FF")
      expect(border.width).to eq(6)
      expect(border.color).to eq("0000FF")
    end
  end

  describe ".double" do
    it "creates double border" do
      border = described_class.double
      expect(border.style).to eq("double")
      expect(border.width).to eq(6)
    end
  end

  describe ".dashed" do
    it "creates dashed border" do
      border = described_class.dashed
      expect(border.style).to eq("dashed")
    end
  end

  describe ".dotted" do
    it "creates dotted border" do
      border = described_class.dotted
      expect(border.style).to eq("dotted")
    end
  end

  describe ".thick" do
    it "creates thick border" do
      border = described_class.thick
      expect(border.style).to eq("thick")
      expect(border.width).to eq(8)
    end
  end

  describe ".none" do
    it "creates no border" do
      border = described_class.none
      expect(border.style).to eq("none")
      expect(border.width).to eq(0)
    end
  end
end
