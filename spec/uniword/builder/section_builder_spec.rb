# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::SectionBuilder do
  it "inherits from BaseBuilder" do
    expect(described_class).to be < Uniword::Builder::BaseBuilder
  end

  it "creates a SectionProperties by default" do
    s = described_class.new
    expect(s.model).to be_a(Uniword::Wordprocessingml::SectionProperties)
  end

  describe "#page_size" do
    it "sets width and height" do
      s = described_class.new
      s.page_size(width: 12_240, height: 15_840)
      expect(s.model.page_size.width).to eq(12_240)
      expect(s.model.page_size.height).to eq(15_840)
    end

    it "sets landscape orientation" do
      s = described_class.new
      s.page_size(orientation: "landscape")
      expect(s.model.page_size.orientation).to eq("landscape")
    end
  end

  describe "#margins" do
    it "sets all margins" do
      s = described_class.new
      s.margins(top: 720, bottom: 720, left: 1440, right: 1440)
      expect(s.model.page_margins.top).to eq(720)
      expect(s.model.page_margins.left).to eq(1440)
    end
  end

  describe "#columns" do
    it "sets column count and spacing" do
      s = described_class.new
      s.columns(count: 2, spacing: 360)
      expect(s.model.columns.num).to eq(2)
      expect(s.model.columns.space).to eq(360)
    end
  end

  describe "#page_numbering" do
    it "sets start and format" do
      s = described_class.new
      s.page_numbering(start: 1, format: "lowerRoman")
      expect(s.model.page_numbering.start).to eq(1)
      expect(s.model.page_numbering.format).to eq("lowerRoman")
    end
  end

  describe "#header / #footer" do
    it "creates a header reference" do
      s = described_class.new
      hf = s.header(type: "default") { |h| h << "Header text" }
      expect(hf).to be_a(Uniword::Builder::HeaderFooterBuilder)
      expect(s.model.header_references.size).to eq(1)
    end

    it "creates a footer reference" do
      s = described_class.new
      s.footer(type: "first") { |f| f << "Footer" }
      expect(s.model.footer_references.size).to eq(1)
    end
  end

  describe "#from_model" do
    it "wraps an existing SectionProperties" do
      model = Uniword::Wordprocessingml::SectionProperties.new
      s = described_class.from_model(model)
      expect(s.model).to eq(model)
    end
  end
end
