# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::WatermarkBuilder do
  describe ".build_shape" do
    it "creates a VML shape with text" do
      shape = described_class.build_shape("DRAFT")
      expect(shape).to be_a(Uniword::Vml::Shape)
    end

    it "sets fill color" do
      shape = described_class.build_shape("DRAFT", color: "FF0000")
      expect(shape.fillcolor).to eq("FF0000")
    end

    it "sets default fill color when none provided" do
      shape = described_class.build_shape("DRAFT")
      expect(shape.fillcolor).to eq("D0D0D0")
    end
  end

  describe ".build_paragraph" do
    it "creates a paragraph containing the watermark" do
      para = described_class.build_paragraph("CONFIDENTIAL")
      expect(para).to be_a(Uniword::Wordprocessingml::Paragraph)
      expect(para.runs.size).to eq(1)
    end
  end
end
