# frozen_string_literal: true

require "spec_helper"

RSpec.describe Uniword::Wordprocessingml::FontReplacer do
  let(:run_props_class) { Uniword::Wordprocessingml::RunProperties }
  let(:fonts_class) { Uniword::Properties::RunFonts }

  def build_document
    Uniword::Wordprocessingml::DocumentRoot.new.tap do |doc|
      doc.body = Uniword::Wordprocessingml::Body.new
      # Tests control style content explicitly; drop the 13 built-in
      # default styles (which carry Calibri fonts).
      doc.styles_configuration.styles = []
    end
  end

  def calibri_run_props
    run_props_class.new(fonts: fonts_class.new(ascii: "Calibri",
                                               h_ansi: "Calibri"))
  end

  describe "#replace" do
    it "rewrites matching fonts in body runs" do
      doc = build_document
      doc.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(
          properties: calibri_run_props,
          text: Uniword::Wordprocessingml::Text.new(content: "x"),
        )],
      )

      count = described_class.new(from: "Calibri", to: "Carlito")
        .replace(doc)

      expect(count).to eq(2)
      fonts = doc.body.paragraphs.first.runs.first.properties.fonts
      expect(fonts.ascii).to eq("Carlito")
      expect(fonts.h_ansi).to eq("Carlito")
    end

    it "rewrites fonts in style definitions" do
      doc = build_document
      style = Uniword::Wordprocessingml::Style.new(
        id: "MyStyle", type: "paragraph", rPr: calibri_run_props,
      )
      doc.styles_configuration.styles << style

      described_class.new(from: "Calibri", to: "Carlito").replace(doc)

      expect(style.rPr.fonts.ascii).to eq("Carlito")
    end

    it "rewrites fonts inside tables" do
      doc = build_document
      cell = Uniword::Wordprocessingml::TableCell.new(
        paragraphs: [Uniword::Wordprocessingml::Paragraph.new(
          runs: [Uniword::Wordprocessingml::Run.new(
            properties: calibri_run_props,
          )],
        )],
      )
      doc.body.tables << Uniword::Wordprocessingml::Table.new(
        rows: [Uniword::Wordprocessingml::TableRow.new(cells: [cell])],
      )

      described_class.new(from: "Calibri", to: "Carlito").replace(doc)

      expect(cell.paragraphs.first.runs.first.properties.fonts.ascii)
        .to eq("Carlito")
    end

    it "rewrites fonts in footnote entries" do
      doc = build_document
      doc.footnotes = Uniword::Wordprocessingml::Footnotes.new(
        footnote_entries: [Uniword::Wordprocessingml::Footnote.new(
          id: 1,
          paragraphs: [Uniword::Wordprocessingml::Paragraph.new(
            runs: [Uniword::Wordprocessingml::Run.new(
              properties: calibri_run_props,
            )],
          )],
        )],
      )

      described_class.new(from: "Calibri", to: "Carlito").replace(doc)

      entry = doc.footnotes.footnote_entries.first
      expect(entry.paragraphs.first.runs.first.properties.fonts.ascii)
        .to eq("Carlito")
    end

    it "rewrites fonts in numbering levels" do
      doc = build_document
      definition = Uniword::Wordprocessingml::NumberingDefinition.new(
        abstract_num_id: 1,
        levels: [Uniword::Wordprocessingml::Level.new(
          ilvl: 0, rPr: calibri_run_props,
        )],
      )
      doc.numbering_configuration.definitions << definition

      described_class.new(from: "Calibri", to: "Carlito").replace(doc)

      expect(definition.levels.first.rPr.fonts.ascii).to eq("Carlito")
    end

    it "leaves theme font references untouched" do
      doc = build_document
      props = run_props_class.new(
        fonts: fonts_class.new(ascii_theme: "minorHAnsi"),
      )
      doc.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(properties: props)],
      )

      count = described_class.new(from: "minorHAnsi", to: "Carlito")
        .replace(doc)

      expect(count).to eq(0)
      expect(props.fonts.ascii_theme).to eq("minorHAnsi")
    end

    it "does not touch non-matching fonts" do
      doc = build_document
      props = run_props_class.new(fonts: fonts_class.new(ascii: "Arial"))
      doc.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(properties: props)],
      )

      count = described_class.new(from: "Calibri", to: "Carlito")
        .replace(doc)

      expect(count).to eq(0)
      expect(props.fonts.ascii).to eq("Arial")
    end
  end
end
