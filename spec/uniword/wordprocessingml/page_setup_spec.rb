# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::PageSetup do
  let(:document) do
    Uniword::Wordprocessingml::DocumentRoot.new.tap do |doc|
      doc.body = Uniword::Wordprocessingml::Body.new
      doc.body.section_properties =
        Uniword::Wordprocessingml::SectionProperties.new
    end
  end

  let(:sect_pr) { document.body.section_properties }

  describe "#apply" do
    it "applies a named paper size" do
      described_class.new(size: "a4").apply(document)

      expect(sect_pr.page_size.width).to eq(11_906)
      expect(sect_pr.page_size.height).to eq(16_838)
    end

    it "swaps dimensions for landscape like Word" do
      described_class.new(size: "a4", orientation: "landscape")
        .apply(document)

      expect(sect_pr.page_size.width).to eq(16_838)
      expect(sect_pr.page_size.height).to eq(11_906)
      expect(sect_pr.page_size.orientation).to eq("landscape")
    end

    it "flips an existing portrait document to landscape" do
      sect_pr.page_size = Uniword::Wordprocessingml::PageSize.new(
        width: 12_240, height: 15_840,
      )

      described_class.new(orientation: "landscape").apply(document)

      expect(sect_pr.page_size.width).to eq(15_840)
      expect(sect_pr.page_size.height).to eq(12_240)
    end

    it "applies uniform margins with unit suffixes" do
      described_class.new(margins: "2cm").apply(document)

      margins = sect_pr.page_margins
      expect(margins.top).to eq(1134)
      expect(margins.left).to eq(1134)
      expect(margins.right).to eq(1134)
      expect(margins.bottom).to eq(1134)
    end

    it "lets per-side overrides win over the uniform value" do
      described_class.new(margins: "1in", top: "3cm").apply(document)

      margins = sect_pr.page_margins
      expect(margins.top).to eq(1701)
      expect(margins.left).to eq(1440)
    end

    it "leaves header/footer/gutter margins untouched" do
      sect_pr.page_margins = Uniword::Wordprocessingml::PageMargins.new(
        header: 720, footer: 720, gutter: 0,
      )

      described_class.new(margins: "1in").apply(document)

      expect(sect_pr.page_margins.header).to eq(720)
      expect(sect_pr.page_margins.gutter).to eq(0)
    end

    it "covers paragraph-level sections too" do
      para = Uniword::Wordprocessingml::Paragraph.new(
        properties: Uniword::Wordprocessingml::ParagraphProperties.new(
          section_properties:
            Uniword::Wordprocessingml::SectionProperties.new,
        ),
      )
      document.body.paragraphs << para

      count = described_class.new(size: "letter").apply(document)

      expect(count).to eq(2)
      expect(para.properties.section_properties.page_size.width)
        .to eq(12_240)
    end

    it "rejects unknown paper sizes" do
      expect { described_class.new(size: "tabloid") }
        .to raise_error(ArgumentError, /Unknown paper size/)
    end

    it "rejects unknown orientations" do
      expect { described_class.new(orientation: "sideways") }
        .to raise_error(ArgumentError, /Unknown orientation/)
    end

    it "rejects unparseable margins" do
      expect { described_class.new(margins: "wide") }
        .to raise_error(ArgumentError, /Invalid margin/)
    end
  end
end
