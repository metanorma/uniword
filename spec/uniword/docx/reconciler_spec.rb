# frozen_string_literal: true

require "spec_helper"
require "uniword/docx"

RSpec.describe Uniword::Docx::Reconciler do
  let(:settings_class) { Uniword::Wordprocessingml::Settings }
  let(:footnotes_class) { Uniword::Wordprocessingml::Footnotes }
  let(:endnotes_class) { Uniword::Wordprocessingml::Endnotes }
  let(:footnote_class) { Uniword::Wordprocessingml::Footnote }
  let(:endnote_class) { Uniword::Wordprocessingml::Endnote }
  let(:footnote_pr_class) { Uniword::Wordprocessingml::FootnotePr }
  let(:endnote_pr_class) { Uniword::Wordprocessingml::EndnotePr }

  def build_package(settings: nil, footnotes: nil, endnotes: nil)
    package = Uniword::Docx::Package.new
    package.settings = settings
    package.footnotes = footnotes
    package.endnotes = endnotes
    package
  end

  describe "footnotes reconciliation" do
    it "creates minimal footnotes when footnote_pr is set but footnotes is nil" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      described_class.new(package).reconcile

      expect(package.footnotes).to be_a(footnotes_class)
      expect(package.footnotes.footnote_entries.size).to eq(2)
    end

    it "creates footnote_pr when footnotes exist but footnote_pr is nil" do
      settings = settings_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: footnotes,
                              endnotes: nil)

      described_class.new(package).reconcile

      expect(settings.footnote_pr).to be_a(footnote_pr_class)
    end

    it "does not change when both footnote_pr and footnotes are set" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      original_footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator",
                             paragraphs: []),
          footnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings,
                              footnotes: original_footnotes, endnotes: nil)

      described_class.new(package).reconcile

      expect(package.footnotes).to equal(original_footnotes)
      expect(settings.footnote_pr).to be_a(footnote_pr_class)
    end

    it "does not change when neither footnote_pr nor footnotes are set" do
      settings = settings_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      described_class.new(package).reconcile

      expect(package.footnotes).to be_nil
    end

    it "injects missing separator entry (id=-1)" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "0", type: "continuationSeparator",
                             paragraphs: []),
          footnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: footnotes,
                              endnotes: nil)

      described_class.new(package).reconcile

      ids = footnotes.footnote_entries.map(&:id)
      expect(ids).to include("-1")
    end

    it "injects missing continuation entry (id=0)" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: footnotes,
                              endnotes: nil)

      described_class.new(package).reconcile

      ids = footnotes.footnote_entries.map(&:id)
      expect(ids).to include("0")
    end
  end

  describe "endnotes reconciliation" do
    it "creates minimal endnotes when endnote_pr is set but endnotes is nil" do
      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      described_class.new(package).reconcile

      expect(package.endnotes).to be_a(endnotes_class)
      expect(package.endnotes.endnote_entries.size).to eq(2)
    end

    it "creates endnote_pr when endnotes exist but endnote_pr is nil" do
      settings = settings_class.new
      endnotes = endnotes_class.new(
        endnote_entries: [
          endnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: nil,
                              endnotes: endnotes)

      described_class.new(package).reconcile

      expect(settings.endnote_pr).to be_a(endnote_pr_class)
    end

    it "does not change when both endnote_pr and endnotes are set" do
      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      original_endnotes = endnotes_class.new(
        endnote_entries: [
          endnote_class.new(id: "-1", type: "separator", paragraphs: []),
          endnote_class.new(id: "0", type: "continuationSeparator",
                            paragraphs: []),
          endnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: nil,
                              endnotes: original_endnotes)

      described_class.new(package).reconcile

      expect(package.endnotes).to equal(original_endnotes)
      expect(settings.endnote_pr).to be_a(endnote_pr_class)
    end

    it "does not change when neither endnote_pr nor endnotes are set" do
      settings = settings_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      described_class.new(package).reconcile

      expect(package.endnotes).to be_nil
    end

    it "injects missing separator entry (id=-1)" do
      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      endnotes = endnotes_class.new(
        endnote_entries: [
          endnote_class.new(id: "0", type: "continuationSeparator",
                            paragraphs: []),
          endnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: nil,
                              endnotes: endnotes)

      described_class.new(package).reconcile

      ids = endnotes.endnote_entries.map(&:id)
      expect(ids).to include("-1")
    end

    it "injects missing continuation entry (id=0)" do
      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      endnotes = endnotes_class.new(
        endnote_entries: [
          endnote_class.new(id: "-1", type: "separator", paragraphs: []),
          endnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: nil,
                              endnotes: endnotes)

      described_class.new(package).reconcile

      ids = endnotes.endnote_entries.map(&:id)
      expect(ids).to include("0")
    end
  end

  describe "profile-dependent reconciliation" do
    let(:profile) { Uniword::Docx::Profile.load(:word_2024_en) }

    def build_package_with_document
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      run.text = Uniword::Wordprocessingml::Text.new(value: "Hello")
      para.runs << run
      package.document.body.paragraphs << para
      package
    end

    it "populates settings with Word defaults when profile is provided" do
      package = build_package_with_document
      described_class.new(package, profile: profile).reconcile

      settings = package.settings
      expect(settings).to be_a(settings_class)
      expect(settings.zoom.percent).to eq(100)
      expect(settings.proof_state.spelling).to eq("clean")
      expect(settings.default_tab_stop.val).to eq("720")
      expect(settings.character_spacing_control.val).to eq("doNotCompress")
      expect(settings.compat).not_to be_nil
      expect(settings.rsids).not_to be_nil
      expect(settings.math_pr).not_to be_nil
      expect(settings.theme_font_lang.val).to eq("en-US")
      expect(settings.theme_font_lang.east_asia).to eq("zh-CN")
      expect(settings.decimal_symbol.val).to eq(".")
      expect(settings.list_separator.val).to eq(",")
      expect(settings.w14_doc_id.val).to match(/^[0-9A-F]+$/)
    end

    it "populates font table with profile fonts" do
      package = build_package_with_document
      described_class.new(package, profile: profile).reconcile

      font_names = package.font_table.fonts.map(&:name)
      expect(font_names).to include("Aptos", "Aptos Display", "Times New Roman")
    end

    it "populates styles with docDefaults and latentStyles" do
      package = build_package_with_document
      described_class.new(package, profile: profile).reconcile

      styles = package.styles
      expect(styles.doc_defaults).not_to be_nil
      expect(styles.doc_defaults.rPrDefault).not_to be_nil
      expect(styles.doc_defaults.pPrDefault).not_to be_nil
      expect(styles.latent_styles).not_to be_nil
      expect(styles.latent_styles.count).to be > 300
    end

    it "ensures default styles exist" do
      package = build_package_with_document
      described_class.new(package, profile: profile).reconcile

      style_ids = package.styles.styles.map(&:id)
      expect(style_ids).to include("Normal", "DefaultParagraphFont",
                                   "TableNormal", "NoList")
    end

    it "populates web settings" do
      package = build_package_with_document
      described_class.new(package, profile: profile).reconcile

      ws = package.web_settings
      expect(ws).not_to be_nil
      expect(ws.mc_ignorable).not_to be_nil
    end

    it "populates app properties" do
      package = build_package_with_document
      described_class.new(package, profile: profile).reconcile

      app = package.app_properties
      expect(app.application).to eq("Microsoft Office Word")
      expect(app.app_version).to eq("16.0000")
    end

    it "populates core properties" do
      package = build_package_with_document
      described_class.new(package, profile: profile).reconcile

      cp = package.core_properties
      expect(cp).not_to be_nil
      expect(cp.revision).to eq("1")
      expect(cp.modified).not_to be_nil
    end

    it "adds tracking attributes to paragraphs" do
      package = build_package_with_document
      described_class.new(package, profile: profile).reconcile

      para = package.document.body.paragraphs.first
      expect(para.rsid_r).to match(/\A00[0-9A-F]{6}\z/)
      expect(para.rsid_r_default).to eq("00000000")
      expect(para.para_id).to match(/\A[0-9A-F]{8}\z/)
      expect(para.text_id).to eq("77777777")
    end

    it "adds rsidR to section properties" do
      package = build_package_with_document
      described_class.new(package, profile: profile).reconcile

      sect_pr = package.document.body.section_properties
      expect(sect_pr).not_to be_nil
      expect(sect_pr.rsid_r).to match(/\A00[0-9A-F]{6}\z/)
    end

    it "does not overwrite existing settings" do
      package = build_package_with_document
      existing_zoom = Uniword::Wordprocessingml::Zoom.new(percent: 200)
      package.settings = settings_class.new(zoom: existing_zoom)
      described_class.new(package, profile: profile).reconcile

      expect(package.settings.zoom.percent).to eq(200)
    end
  end

  describe "Group 3: Package consistency" do
    let(:profile) { Uniword::Docx::Profile.load(:word_2024_en) }

    def build_full_package
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      run.text = Uniword::Wordprocessingml::Text.new(value: "Hello")
      para.runs << run
      package.document.body.paragraphs << para
      package.content_types = Uniword::Docx::Package.minimal_content_types
      package.package_rels = Uniword::Docx::Package.minimal_package_rels
      package.document_rels = Uniword::Docx::Package.minimal_document_rels
      package
    end

    describe "content types" do
      it "only includes rels and xml defaults" do
        package = build_full_package
        described_class.new(package, profile: profile).reconcile

        defaults = package.content_types.defaults.map(&:extension)
        expect(defaults).to eq(%w[rels xml])
      end

      it "includes overrides for all present parts" do
        package = build_full_package
        described_class.new(package, profile: profile).reconcile

        part_names = package.content_types.overrides.map(&:part_name)
        expect(part_names).to include("/word/document.xml")
        expect(part_names).to include("/word/styles.xml")
        expect(part_names).to include("/word/settings.xml")
        expect(part_names).to include("/word/fontTable.xml")
        expect(part_names).to include("/word/webSettings.xml")
        expect(part_names).to include("/word/theme/theme1.xml")
        expect(part_names).to include("/docProps/core.xml")
        expect(part_names).to include("/docProps/app.xml")
      end

      it "excludes overrides for absent parts" do
        package = build_full_package
        # No footnotes, endnotes, or numbering
        described_class.new(package, profile: profile).reconcile

        part_names = package.content_types.overrides.map(&:part_name)
        expect(part_names).not_to include("/word/footnotes.xml")
        expect(part_names).not_to include("/word/endnotes.xml")
        expect(part_names).not_to include("/word/numbering.xml")
      end

      it "includes overrides for footnotes when present" do
        package = build_full_package
        settings = Uniword::Wordprocessingml::Settings.new
        settings.footnote_pr = Uniword::Wordprocessingml::FootnotePr.new
        package.settings = settings
        described_class.new(package, profile: profile).reconcile

        part_names = package.content_types.overrides.map(&:part_name)
        expect(part_names).to include("/word/footnotes.xml")
      end
    end

    describe "package relationships" do
      it "uses rId1 for officeDocument" do
        package = build_full_package
        described_class.new(package, profile: profile).reconcile

        rId1 = package.package_rels.relationships.find { |r| r.id == "rId1" }
        expect(rId1.target).to eq("word/document.xml")
        expect(rId1.type.to_s).to include("officeDocument")
      end

      it "uses rId2 for core-properties" do
        package = build_full_package
        described_class.new(package, profile: profile).reconcile

        rId2 = package.package_rels.relationships.find { |r| r.id == "rId2" }
        expect(rId2.target).to eq("docProps/core.xml")
        expect(rId2.type.to_s).to include("core-properties")
      end

      it "uses rId3 for extended-properties" do
        package = build_full_package
        described_class.new(package, profile: profile).reconcile

        rId3 = package.package_rels.relationships.find { |r| r.id == "rId3" }
        expect(rId3.target).to eq("docProps/app.xml")
        expect(rId3.type.to_s).to include("extended-properties")
      end

      it "preserves non-standard rels" do
        package = build_full_package
        package.package_rels.relationships <<
          Uniword::Ooxml::Relationships::Relationship.new(
            id: "rIdCustom",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/custom-properties",
            target: "docProps/custom.xml",
          )

        described_class.new(package, profile: profile).reconcile

        custom = package.package_rels.relationships.find do |r|
          r.id == "rIdCustom"
        end
        expect(custom).not_to be_nil
        expect(custom.target).to eq("docProps/custom.xml")
      end
    end

    describe "document relationships" do
      it "uses correct rId ordering for standard parts" do
        package = build_full_package
        described_class.new(package, profile: profile).reconcile

        rels = package.document_rels.relationships
        rId1 = rels.find { |r| r.id == "rId1" }
        rId2 = rels.find { |r| r.id == "rId2" }
        rId3 = rels.find { |r| r.id == "rId3" }
        rId4 = rels.find { |r| r.id == "rId4" }
        rId5 = rels.find { |r| r.id == "rId5" }

        expect(rId1.target).to eq("styles.xml")
        expect(rId2.target).to eq("settings.xml")
        expect(rId3.target).to eq("webSettings.xml")
        expect(rId4.target).to eq("fontTable.xml")
        expect(rId5.target).to eq("theme/theme1.xml")
      end

      it "does not include theme rId when theme is absent" do
        package = build_full_package
        # No profile → no theme
        described_class.new(package).reconcile

        rId5 = package.document_rels.relationships.find { |r| r.id == "rId5" }
        expect(rId5).to be_nil
      end

      it "preserves non-standard rels" do
        package = build_full_package
        package.document_rels.relationships <<
          Uniword::Ooxml::Relationships::Relationship.new(
            id: "rIdExtra",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
            target: "media/image1.png",
          )

        described_class.new(package, profile: profile).reconcile

        extra = package.document_rels.relationships.find do |r|
          r.id == "rIdExtra"
        end
        expect(extra).not_to be_nil
        expect(extra.target).to eq("media/image1.png")
      end
    end
  end
end
