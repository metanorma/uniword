# frozen_string_literal: true

require "spec_helper"
require "uniword/builder"

RSpec.describe Uniword::Builder::StyleBuilder do
  describe "#initialize" do
    it "creates a Style with name and base" do
      sb = described_class.new("MyStyle", base_on: "Heading1")
      expect(sb.model).to be_a(Uniword::Wordprocessingml::Style)
      expect(sb.model.name.val).to eq("MyStyle")
      expect(sb.model.basedOn.val).to eq("Heading1")
    end
  end

  describe "run properties" do
    it "sets font_size" do
      sb = described_class.new("S")
      sb.font_size(14)
      expect(sb.model.rPr.size.value).to eq(28)
    end

    it "sets bold" do
      sb = described_class.new("S")
      sb.bold(true)
      expect(sb.model.rPr.bold).to be_a(Uniword::Properties::Bold)
    end

    it "sets italic" do
      sb = described_class.new("S")
      sb.italic(true)
      expect(sb.model.rPr.italic).to be_a(Uniword::Properties::Italic)
    end

    it "sets color" do
      sb = described_class.new("S")
      sb.color("FF0000")
      expect(sb.model.rPr.color.value).to eq("FF0000")
    end

    it "sets font name" do
      sb = described_class.new("S")
      sb.font("Arial")
      expect(sb.model.rPr.font).to eq("Arial")
    end
  end

  describe "paragraph properties" do
    it "sets alignment" do
      sb = described_class.new("S")
      sb.align(:center)
      expect(sb.model.pPr.alignment).to eq("center")
    end

    it "sets spacing" do
      sb = described_class.new("S")
      sb.spacing(before: 240, after: 120)
      spacing = sb.model.pPr.spacing.first
      expect(spacing.before).to eq(240)
      expect(spacing.after).to eq(120)
    end

    # A .dotx style whose spacing Word split across two w:spacing elements.
    context "when a later entry already carries the field" do
      let(:two_entries_xml) do
        <<~XML
          <w:pPr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
            <w:spacing w:before="0"/>
            <w:spacing w:before="777" w:line="240"/>
          </w:pPr>
        XML
      end
      let(:style_builder) do
        sb = described_class.new("S")
        sb.model.pPr =
          Uniword::Wordprocessingml::ParagraphProperties.from_xml(two_entries_xml)
        sb
      end

      it "sets spacing without leaving the stale value standing" do
        style_builder.spacing(before: 111)

        expect(style_builder.model.pPr.spacing.map(&:before)).to eq([111, nil])
        expect(style_builder.model.pPr.spacing.map(&:line)).to eq([nil, 240])
      end
    end
  end

  describe "#build" do
    it "returns the Style model" do
      sb = described_class.new("S")
      expect(sb.build).to eq(sb.model)
    end
  end
end
