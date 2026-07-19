# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::StyleCleanup do
  let(:style_class) { Uniword::Wordprocessingml::Style }
  let(:doc) do
    Uniword::Wordprocessingml::DocumentRoot.new.tap do |d|
      d.body = Uniword::Wordprocessingml::Body.new
      d.styles_configuration.styles = []
    end
  end

  def add_style(id, default: false, based_on: nil)
    style = style_class.new(type: "paragraph", styleId: id)
    style.default = true if default
    style.basedOn = Uniword::Wordprocessingml::BasedOn.new(val: based_on) if based_on
    doc.styles_configuration.styles << style
    style
  end

  def add_styled_paragraph(style_id)
    para = Uniword::Wordprocessingml::Paragraph.new(
      properties: Uniword::Wordprocessingml::ParagraphProperties.new(
        style: [Uniword::Properties::StyleReference.new(value: style_id)],
      ),
    )
    doc.body.paragraphs << para
  end

  describe "#remove?" do
    it "removes a style by id" do
      add_style("Obsolete")

      expect(described_class.new(doc).remove?("Obsolete")).to be(true)
      expect(doc.styles_configuration.styles.map(&:styleId))
        .not_to include("Obsolete")
    end

    it "refuses to remove default styles" do
      add_style("Normal", default: true)

      expect(described_class.new(doc).remove?("Normal")).to be(false)
      expect(doc.styles_configuration.styles.map(&:styleId))
        .to include("Normal")
    end
  end

  describe "#unused_ids" do
    it "keeps styles referenced by body paragraphs" do
      add_style("BodyText")
      add_style("Obsolete")
      add_styled_paragraph("BodyText")

      expect(described_class.new(doc).unused_ids).to eq(["Obsolete"])
    end

    it "keeps styles reachable through basedOn chains" do
      add_style("BodyText")
      add_style("Derived", based_on: "BodyText")
      add_style("Obsolete")
      add_styled_paragraph("Derived")

      expect(described_class.new(doc).unused_ids).to eq(["Obsolete"])
    end

    it "keeps default styles even when unreferenced" do
      add_style("Normal", default: true)
      add_style("Obsolete")

      expect(described_class.new(doc).unused_ids).to eq(["Obsolete"])
    end
  end

  describe "#remove_unused" do
    it "removes only unreferenced styles and returns their ids" do
      add_style("BodyText")
      add_style("Obsolete1")
      add_style("Obsolete2")
      add_styled_paragraph("BodyText")

      removed = described_class.new(doc).remove_unused

      expect(removed).to match_array(%w[Obsolete1 Obsolete2])
      expect(doc.styles_configuration.styles.map(&:styleId))
        .to eq(["BodyText"])
    end
  end
end
