# frozen_string_literal: true

require "spec_helper"

RSpec.describe "mc:Ignorable reconciliation" do
  let(:profile) { Uniword::Docx::Profile.defaults }
  let(:package) { Uniword::Docx::Package.new }
  let(:reconciler) { Uniword::Docx::Reconciler.new(package, profile: profile) }

  let(:full_ignorable_prefixes) do
    Uniword::Ooxml::Namespaces::FULL_IGNORABLE_PREFIXES.split.sort
  end

  let(:extension_prefixes) do
    Uniword::Ooxml::Namespaces::EXTENSION_PREFIXES.split.sort
  end

  def parse_mc_ignorable(model)
    model.mc_ignorable.to_s.split.sort
  end

  before do
    package.document = Uniword::Wordprocessingml::DocumentRoot.new
    package.document.body = Uniword::Wordprocessingml::Body.new
    package.document.body.paragraphs = []
    package.footnotes = Uniword::Wordprocessingml::Footnotes.new(
      footnote_entries: [
        Uniword::Wordprocessingml::Footnote.new(id: "-1", type: "separator",
          paragraphs: [Uniword::Wordprocessingml::Paragraph.new]),
        Uniword::Wordprocessingml::Footnote.new(id: "0", type: "continuationSeparator",
          paragraphs: [Uniword::Wordprocessingml::Paragraph.new]),
      ]
    )
    package.endnotes = Uniword::Wordprocessingml::Endnotes.new(
      endnote_entries: [
        Uniword::Wordprocessingml::Endnote.new(id: "-1", type: "separator",
          paragraphs: [Uniword::Wordprocessingml::Paragraph.new]),
        Uniword::Wordprocessingml::Endnote.new(id: "0", type: "continuationSeparator",
          paragraphs: [Uniword::Wordprocessingml::Paragraph.new]),
      ]
    )
    package.numbering = Uniword::Wordprocessingml::NumberingConfiguration.new
    package.settings = Uniword::Wordprocessingml::Settings.new
    package.styles = Uniword::Wordprocessingml::StylesConfiguration.new(include_defaults: false)
    package.font_table = Uniword::Wordprocessingml::FontTable.new
    package.web_settings = Uniword::Wordprocessingml::WebSettings.new
  end

  describe "setting mc:Ignorable to full prefix lists" do
    it "sets document mc_ignorable to FULL_IGNORABLE" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.document)).to eq(full_ignorable_prefixes)
    end

    it "sets settings mc_ignorable to EXTENSION_PREFIXES" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.settings)).to eq(extension_prefixes)
    end

    it "sets styles mc_ignorable to EXTENSION_PREFIXES" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.styles)).to eq(extension_prefixes)
    end

    it "sets numbering mc_ignorable to FULL_IGNORABLE" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.numbering)).to eq(full_ignorable_prefixes)
    end

    it "sets footnotes mc_ignorable to FULL_IGNORABLE" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.footnotes)).to eq(full_ignorable_prefixes)
    end

    it "sets endnotes mc_ignorable to FULL_IGNORABLE" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.endnotes)).to eq(full_ignorable_prefixes)
    end

    it "sets font_table mc_ignorable to EXTENSION_PREFIXES" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.font_table)).to eq(extension_prefixes)
    end

    it "sets web_settings mc_ignorable to EXTENSION_PREFIXES" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.web_settings)).to eq(extension_prefixes)
    end
  end

  describe "overwriting stale template mc:Ignorable" do
    it "overwrites stale document mc_ignorable with FULL_IGNORABLE" do
      package.document.mc_ignorable =
        Uniword::Ooxml::Types::McIgnorable.new("w14 w15")

      reconciler.reconcile

      expect(parse_mc_ignorable(package.document)).to eq(full_ignorable_prefixes)
    end

    it "overwrites stale settings mc_ignorable with EXTENSION_PREFIXES" do
      package.settings.mc_ignorable =
        Uniword::Ooxml::Types::McIgnorable.new("w14")

      reconciler.reconcile

      expect(parse_mc_ignorable(package.settings)).to eq(extension_prefixes)
    end

    it "overwrites stale styles mc_ignorable with EXTENSION_PREFIXES" do
      package.styles.mc_ignorable =
        Uniword::Ooxml::Types::McIgnorable.new("w14")

      reconciler.reconcile

      expect(parse_mc_ignorable(package.styles)).to eq(extension_prefixes)
    end

    it "overwrites stale numbering mc_ignorable with FULL_IGNORABLE" do
      package.numbering.mc_ignorable =
        Uniword::Ooxml::Types::McIgnorable.new("w14")

      reconciler.reconcile

      expect(parse_mc_ignorable(package.numbering)).to eq(full_ignorable_prefixes)
    end

    it "overwrites stale footnotes mc_ignorable with FULL_IGNORABLE" do
      package.footnotes.mc_ignorable =
        Uniword::Ooxml::Types::McIgnorable.new("w14")

      reconciler.reconcile

      expect(parse_mc_ignorable(package.footnotes)).to eq(full_ignorable_prefixes)
    end

    it "overwrites stale endnotes mc_ignorable with FULL_IGNORABLE" do
      package.endnotes.mc_ignorable =
        Uniword::Ooxml::Types::McIgnorable.new("w14")

      reconciler.reconcile

      expect(parse_mc_ignorable(package.endnotes)).to eq(full_ignorable_prefixes)
    end

    it "sets font_table mc_ignorable to EXTENSION_PREFIXES when nil" do
      package.font_table.mc_ignorable = nil

      reconciler.reconcile

      expect(parse_mc_ignorable(package.font_table)).to eq(extension_prefixes)
    end

    it "overwrites stale web_settings mc_ignorable with EXTENSION_PREFIXES" do
      package.web_settings.mc_ignorable =
        Uniword::Ooxml::Types::McIgnorable.new("w14")

      reconciler.reconcile

      expect(parse_mc_ignorable(package.web_settings)).to eq(extension_prefixes)
    end
  end

  describe "w16du and w16sdtfl in mc:Ignorable" do
    it "includes w16du in document mc:Ignorable" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.document)).to include("w16du")
    end

    it "includes w16sdtfl in document mc:Ignorable" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.document)).to include("w16sdtfl")
    end

    it "includes w16du in settings mc:Ignorable" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.settings)).to include("w16du")
    end

    it "includes w16sdtfl in settings mc:Ignorable" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.settings)).to include("w16sdtfl")
    end

    it "includes wp14 in document mc:Ignorable (FULL_IGNORABLE)" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.document)).to include("wp14")
    end

    it "excludes wp14 from settings mc:Ignorable (EXTENSION_PREFIXES)" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.settings)).not_to include("wp14")
    end

    it "includes wp14 in numbering mc:Ignorable" do
      reconciler.reconcile

      expect(parse_mc_ignorable(package.numbering)).to include("wp14")
    end
  end
end
