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
  let(:para_class) { Uniword::Wordprocessingml::Paragraph }

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

    it "creates separator footnotes with proper paragraph spacing" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      package = build_package(settings: settings, footnotes: nil, endnotes: nil)

      described_class.new(package).reconcile

      sep = package.footnotes.footnote_entries.find { |e| e.id == "-1" }
      para = sep.paragraphs.first
      expect(para).not_to be_nil
      expect(para.properties).not_to be_nil
      spacing = para.properties.spacing
      expect(spacing).not_to be_nil
      expect(spacing.after).to eq(0)
      expect(spacing.line).to eq(240)
      expect(spacing.line_rule).to eq("auto")
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

    it "strips invalid w:type from normal footnotes" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", type: "normal", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: footnotes)

      described_class.new(package).reconcile

      fn1 = footnotes.footnote_entries.find { |e| e.id == "1" }
      expect(fn1.type).to be_nil
    end

    it "preserves valid separator types" do
      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
        ],
      )
      package = build_package(settings: settings, footnotes: footnotes)

      described_class.new(package).reconcile

      sep = footnotes.footnote_entries.find { |e| e.id == "-1" }
      cont = footnotes.footnote_entries.find { |e| e.id == "0" }
      expect(sep.type).to eq("separator")
      expect(cont.type).to eq("continuationSeparator")
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

    it "sets mc:Ignorable to FULL_IGNORABLE for document" do
      package = build_package_with_document
      described_class.new(package, profile: profile).reconcile

      ignorable = package.document.mc_ignorable.to_s
      expect(ignorable).to include("w14")
      expect(ignorable).to include("w15")
      expect(ignorable).to include("w16")
      expect(ignorable).to include("wp14")
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

    it "keeps DefaultParagraphFont at original position when adding semiHidden" do
      package = build_package_with_document
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(include_defaults: false)
      package.styles = styles

      # Build a style collection where DefaultParagraphFont is at index 2 without semiHidden
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", default: true, styleId: "Normal",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Normal"),
      ))
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "Heading1",
        name: Uniword::Wordprocessingml::StyleName.new(val: "heading 1"),
      ))
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "character", default: true, styleId: "DefaultParagraphFont",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Default Paragraph Font"),
        uiPriority: Uniword::Wordprocessingml::UiPriority.new(val: 1),
        unhideWhenUsed: Uniword::Wordprocessingml::UnhideWhenUsed.new,
      ))

      dpf_index_before = styles.styles.index { |s| s.id == "DefaultParagraphFont" }
      expect(dpf_index_before).to eq(2)

      described_class.new(package, profile: profile).reconcile

      dpf = styles.styles.find { |s| s.id == "DefaultParagraphFont" }
      expect(dpf).not_to be_nil
      expect(dpf.semiHidden).not_to be_nil

      dpf_index_after = styles.styles.index { |s| s.id == "DefaultParagraphFont" }
      expect(dpf_index_after).to eq(dpf_index_before),
        "DefaultParagraphFont moved from position #{dpf_index_before} to #{dpf_index_after}"
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

      it "preserves non-standard rels with sequential rIds" do
        package = build_full_package
        package.document_rels.relationships <<
          Uniword::Ooxml::Relationships::Relationship.new(
            id: "rIdExtra",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
            target: "media/image1.png",
          )

        described_class.new(package, profile: profile).reconcile

        extra = package.document_rels.relationships.find do |r|
          r.target == "media/image1.png"
        end
        expect(extra).not_to be_nil
        expect(extra.type).to include("image")

        # All rIds must be sequential
        ids = package.document_rels.relationships.map(&:id)
        ids.each_with_index do |rid, i|
          expect(rid).to eq("rId#{i + 1}")
        end
      end

      it "renumbers non-sequential template rIds to sequential" do
        package = build_full_package

        rels = package.document_rels
        rels.relationships.clear
        rels.relationships << Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId1", type: ".../styles", target: "styles.xml",
        )
        rels.relationships << Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId13", type: ".../fontTable", target: "fontTable.xml",
        )
        rels.relationships << Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId99", type: ".../header", target: "header1.xml",
        )

        described_class.new(package, profile: profile).reconcile

        ids = rels.relationships.map(&:id)
        ids.each_with_index do |rid, i|
          expect(rid).to eq("rId#{i + 1}"),
                         "Expected rId#{i + 1} at position #{i}, got #{rid}"
        end
      end

      it "updates sectPr references after renumbering" do
        package = build_full_package

        header = Uniword::Wordprocessingml::Header.new
        hdr_para = Uniword::Wordprocessingml::Paragraph.new
        hdr_para.runs << Uniword::Wordprocessingml::Run.new(
          text: Uniword::Wordprocessingml::Text.new(value: "Header"),
        )
        header.paragraphs << hdr_para
        package.document.headers ||= {}
        package.document.headers["default"] = header

        # Ensure section properties exist with a header reference using rId99
        sect_pr = package.document.body.section_properties
        unless sect_pr
          sect_pr = Uniword::Wordprocessingml::SectionProperties.new
          package.document.body.section_properties = sect_pr
        end
        sect_pr.header_references ||= []
        sect_pr.header_references <<
          Uniword::Wordprocessingml::HeaderReference.new(type: "default", r_id: "rId99")

        rels = package.document_rels
        rels.relationships << Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId99", type: ".../header", target: "header1.xml",
        )

        described_class.new(package, profile: profile).reconcile

        ref = sect_pr.header_references.find { |r| r.type == "default" }
        expect(ref).not_to be_nil
        expect(ref.r_id).to match(/\ArId\d+\z/)
        expect(rels.relationships.map(&:id)).to include(ref.r_id)
      end
    end
  end

  describe "clear_stored_namespace_plans" do
    let(:profile) { Uniword::Docx::Profile.load(:word_2024_en) }

    it "clears xml parse state on all parts" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.import_declaration_plan = :some_plan
      package.document.pending_plan_root_element = "some_element"
      described_class.new(package, profile: profile).reconcile
      expect(package.document.import_declaration_plan).to be_nil
      expect(package.document.pending_plan_root_element).to be_nil
    end

    it "clears pending_plan_root_element on all parts" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.pending_plan_root_element = "some_element_ref"
      described_class.new(package, profile: profile).reconcile
      expect(package.document.pending_plan_root_element).to be_nil
    end

    it "clears import_declaration_plan on all parts" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.import_declaration_plan = :some_plan
      described_class.new(package, profile: profile).reconcile
      expect(package.document.import_declaration_plan).to be_nil
    end

    it "calls clear_xml_parse_state! on all parts" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.import_declaration_plan = :plan
      described_class.new(package, profile: profile).reconcile
      expect(package.document.import_declaration_plan).to be_nil
      expect(package.document.pending_plan_root_element).to be_nil
    end

    it "handles nil parts gracefully" do
      package = Uniword::Docx::Package.new
      expect do
        described_class.new(package).reconcile
      end.not_to raise_error
    end
  end

  describe "note reference validation (R10)" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:fn_ref_class) { Uniword::Wordprocessingml::FootnoteReference }
    let(:en_ref_class) { Uniword::Wordprocessingml::EndnoteReference }
    let(:table_class) { Uniword::Wordprocessingml::Table }
    let(:row_class) { Uniword::Wordprocessingml::TableRow }
    let(:cell_class) { Uniword::Wordprocessingml::TableCell }
    let(:body_class) { Uniword::Wordprocessingml::Body }

    def build_package_with_refs(ref_ids_in_tables: [], ref_ids_in_paras: [])
      document = Uniword::Wordprocessingml::DocumentRoot.new

      paras = ref_ids_in_paras.map do |id|
        para_class.new(runs: [run_class.new(footnote_reference: fn_ref_class.new(id: id))])
      end

      if ref_ids_in_tables.any?
        cells = ref_ids_in_tables.map do |id|
          cell_class.new(
            paragraphs: [para_class.new(
              runs: [run_class.new(footnote_reference: fn_ref_class.new(id: id))]
            )]
          )
        end
        tbl = table_class.new(rows: [row_class.new(cells: cells)])
        document.body = body_class.new(paragraphs: paras, tables: [tbl])
      else
        document.body = body_class.new(paragraphs: paras)
      end

      package = Uniword::Docx::Package.new
      package.document = document
      package
    end

    it "finds footnote references in table cells" do
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
          footnote_class.new(id: "2", paragraphs: [para_class.new]),
          footnote_class.new(id: "3", paragraphs: [para_class.new]),
        ],
      )
      package = build_package_with_refs(
        ref_ids_in_paras: ["1"],
        ref_ids_in_tables: ["2", "3"],
      )
      package.footnotes = footnotes

      described_class.new(package).reconcile

      r10_fixes = described_class.new(package).instance_variable_get(:@applied_fixes)
      described_class.new(package).reconcile
      expect(package.footnotes.footnote_entries.map(&:id)).to include("1", "2", "3")
    end

    it "creates missing footnote definitions for references in table cells" do
      package = build_package_with_refs(
        ref_ids_in_paras: ["1"],
        ref_ids_in_tables: ["2", "99"],
      )
      package.footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
        ],
      )

      reconciler = described_class.new(package)
      reconciler.reconcile

      ids = package.footnotes.footnote_entries.map(&:id)
      expect(ids).to include("99")
      r10 = reconciler.applied_fixes.find { |f| f[:validity_rule] == "R10" }
      expect(r10).not_to be_nil
      expect(r10[:message]).to include("99")
    end

    it "creates footnotes.xml when references exist but no footnotes part" do
      package = build_package_with_refs(ref_ids_in_paras: ["1"])

      reconciler = described_class.new(package)
      reconciler.reconcile

      expect(package.footnotes).to be_a(footnotes_class)
      ids = package.footnotes.footnote_entries.map(&:id)
      expect(ids).to include("-1", "0", "1")
    end

    it "returns empty when no footnote references exist" do
      document = Uniword::Wordprocessingml::DocumentRoot.new
      document.body = body_class.new
      package = Uniword::Docx::Package.new
      package.document = document

      reconciler = described_class.new(package)
      reconciler.reconcile

      r10 = reconciler.applied_fixes.find { |f| f[:validity_rule] == "R10" }
      expect(r10).to be_nil
    end
  end

  describe "note definition integrity (R15, R16)" do
    def build_package_with_footnotes(footnote_entries)
      document = Uniword::Wordprocessingml::DocumentRoot.new
      document.body = Uniword::Wordprocessingml::Body.new
      package = Uniword::Docx::Package.new
      package.document = document
      package.footnotes = footnotes_class.new(
        footnote_entries: footnote_entries,
      )
      package
    end

    def build_package_with_endnotes(endnote_entries)
      document = Uniword::Wordprocessingml::DocumentRoot.new
      document.body = Uniword::Wordprocessingml::Body.new
      package = Uniword::Docx::Package.new
      package.document = document
      package.endnotes = endnotes_class.new(
        endnote_entries: endnote_entries,
      )
      package
    end

    describe "R15: strip_invalid_note_types" do
      it "removes w:type from regular footnote definitions" do
        package = build_package_with_footnotes([
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", type: "normal", paragraphs: [para_class.new]),
          footnote_class.new(id: "2", type: "someOtherType", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        entries = package.footnotes.footnote_entries
        expect(entries.find { |e| e.id == "1" }.type).to be_nil
        expect(entries.find { |e| e.id == "2" }.type).to be_nil

        r15 = reconciler.applied_fixes.find { |f| f[:validity_rule] == "R15" }
        expect(r15).not_to be_nil
        expect(r15[:message]).to include("2")
        expect(r15[:message]).to include("1", "2")
      end

      it "preserves w:type on separator and continuation entries" do
        package = build_package_with_footnotes([
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        entries = package.footnotes.footnote_entries
        expect(entries.find { |e| e.id == "-1" }.type).to eq("separator")
        expect(entries.find { |e| e.id == "0" }.type).to eq("continuationSeparator")
        expect(entries.find { |e| e.id == "1" }.type).to be_nil

        r15 = reconciler.applied_fixes.find { |f| f[:validity_rule] == "R15" }
        expect(r15).to be_nil
      end

      it "removes w:type from regular endnote definitions" do
        package = build_package_with_endnotes([
          endnote_class.new(id: "-1", type: "separator", paragraphs: []),
          endnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          endnote_class.new(id: "1", type: "normal", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        expect(package.endnotes.endnote_entries.find { |e| e.id == "1" }.type).to be_nil
        r15 = reconciler.applied_fixes.select { |f| f[:validity_rule] == "R15" }
        expect(r15.size).to eq(1)
        expect(r15.first[:message]).to include("endnote")
      end

      it "does nothing when no invalid types exist" do
        package = build_package_with_footnotes([
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        r15 = reconciler.applied_fixes.select { |f| f[:validity_rule] == "R15" }
        expect(r15).to be_empty
      end

      it "does nothing when footnotes and endnotes are nil" do
        document = Uniword::Wordprocessingml::DocumentRoot.new
        document.body = Uniword::Wordprocessingml::Body.new
        package = Uniword::Docx::Package.new
        package.document = document

        reconciler = described_class.new(package)
        reconciler.reconcile

        r15 = reconciler.applied_fixes.select { |f| f[:validity_rule] == "R15" }
        expect(r15).to be_empty
      end
    end

    describe "R16: deduplicate_note_ids" do
      it "removes duplicate footnote IDs keeping first occurrence" do
        package = build_package_with_footnotes([
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
          footnote_class.new(id: "2", paragraphs: [para_class.new]),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
          footnote_class.new(id: "3", paragraphs: [para_class.new]),
          footnote_class.new(id: "2", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        ids = package.footnotes.footnote_entries.map(&:id)
        expect(ids).to eq(["-1", "0", "1", "2", "3"])
        expect(ids.uniq).to eq(ids)

        r16 = reconciler.applied_fixes.find { |f| f[:validity_rule] == "R16" }
        expect(r16).not_to be_nil
        expect(r16[:message]).to include("2")
        expect(r16[:message]).to include("1", "2")
      end

      it "removes duplicate endnote IDs" do
        package = build_package_with_endnotes([
          endnote_class.new(id: "-1", type: "separator", paragraphs: []),
          endnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          endnote_class.new(id: "1", paragraphs: [para_class.new]),
          endnote_class.new(id: "1", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        ids = package.endnotes.endnote_entries.map(&:id)
        expect(ids).to eq(["-1", "0", "1"])

        r16 = reconciler.applied_fixes.select { |f| f[:validity_rule] == "R16" }
        expect(r16.size).to eq(1)
        expect(r16.first[:message]).to include("endnote")
      end

      it "does nothing when no duplicates exist" do
        package = build_package_with_footnotes([
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new]),
          footnote_class.new(id: "2", paragraphs: [para_class.new]),
        ])

        reconciler = described_class.new(package)
        reconciler.reconcile

        r16 = reconciler.applied_fixes.select { |f| f[:validity_rule] == "R16" }
        expect(r16).to be_empty
      end

      it "does nothing when footnotes and endnotes are nil" do
        document = Uniword::Wordprocessingml::DocumentRoot.new
        document.body = Uniword::Wordprocessingml::Body.new
        package = Uniword::Docx::Package.new
        package.document = document

        reconciler = described_class.new(package)
        reconciler.reconcile

        r16 = reconciler.applied_fixes.select { |f| f[:validity_rule] == "R16" }
        expect(r16).to be_empty
      end
    end
  end

  describe "table reconciliation" do
    let(:table_class) { Uniword::Wordprocessingml::Table }
    let(:table_props_class) { Uniword::Wordprocessingml::TableProperties }
    let(:grid_class) { Uniword::Wordprocessingml::TableGrid }
    let(:grid_col_class) { Uniword::Wordprocessingml::GridCol }
    let(:table_width_class) { Uniword::Properties::TableWidth }
    let(:table_look_class) { Uniword::Properties::TableLook }
    let(:row_class) { Uniword::Wordprocessingml::TableRow }
    let(:cell_class) { Uniword::Wordprocessingml::TableCell }

    def build_package_with_table(table)
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.tables << table
      package
    end

    def build_table_with_cells(col_count, row_count)
      rows = row_count.times.map do
        cells = col_count.times.map { cell_class.new }
        row_class.new(cells: cells)
      end
      table_class.new(rows: rows)
    end

    it "adds tblPr when missing" do
      table = build_table_with_cells(2, 1)
      table.properties = nil
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      expect(table.properties).to be_a(table_props_class)
    end

    it "adds tblW with defaults when missing" do
      table = build_table_with_cells(2, 1)
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      tw = table.properties.table_width
      expect(tw).not_to be_nil
      expect(tw.w).to eq(0)
      expect(tw.type).to eq("auto")
    end

    it "adds tblLook with defaults when missing" do
      table = build_table_with_cells(2, 1)
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      look = table.properties.table_look
      expect(look).not_to be_nil
      expect(look.val).to eq("04A0")
      expect(look.first_row).to eq(1)
      expect(look.no_v_band).to eq(1)
    end

    it "creates tblGrid with correct column count" do
      table = build_table_with_cells(3, 2)
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      expect(table.grid).not_to be_nil
      expect(table.grid.columns.size).to eq(3)
    end

    it "adjusts tblGrid when column count mismatches" do
      table = build_table_with_cells(3, 1)
      table.grid = grid_class.new(columns: [grid_col_class.new])
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      expect(table.grid.columns.size).to eq(3)
    end

    it "fills missing tblLook attributes on existing table" do
      table = build_table_with_cells(2, 1)
      table.properties = table_props_class.new(
        table_look: table_look_class.new,
      )
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      look = table.properties.table_look
      expect(look.val).to eq("04A0")
      expect(look.first_row).to eq(1)
    end

    it "does not overwrite existing valid table structure" do
      table = build_table_with_cells(2, 1)
      table.properties = table_props_class.new(
        table_width: table_width_class.new(w: 5000, type: "dxa"),
        table_look: table_look_class.new(
          val: "01A0", first_row: 0, last_row: 0,
          first_column: 0, last_column: 0,
          no_h_band: 0, no_v_band: 0,
        ),
      )
      table.grid = grid_class.new(
        columns: [grid_col_class.new(width: 2500),
                  grid_col_class.new(width: 2500)],
      )
      package = build_package_with_table(table)

      reconciler = described_class.new(package)
      reconciler.reconcile

      look = table.properties.table_look
      expect(look.val).to eq("01A0")
      expect(look.first_row).to eq(0)
      expect(table.properties.table_width.w).to eq(5000)
      expect(table.properties.table_width.type).to eq("dxa")
    end
  end

  describe "referential integrity" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:text_class) { Uniword::Wordprocessingml::Text }
    let(:para_class) { Uniword::Wordprocessingml::Paragraph }
    let(:fn_ref_class) { Uniword::Wordprocessingml::FootnoteReference }
    let(:en_ref_class) { Uniword::Wordprocessingml::EndnoteReference }
    let(:header_ref_class) { Uniword::Wordprocessingml::HeaderReference }
    let(:footer_ref_class) { Uniword::Wordprocessingml::FooterReference }
    let(:sect_pr_class) { Uniword::Wordprocessingml::SectionProperties }
    let(:page_size_class) { Uniword::Wordprocessingml::PageSize }

    def build_package_with_body_paragraphs(*paras)
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      paras.each { |p| package.document.body.paragraphs << p }
      package
    end

    it "removes dangling footnote references from body" do
      run = run_class.new(
        text: text_class.new(value: "text"),
        footnote_reference: fn_ref_class.new(id: "99"),
      )
      para = para_class.new(runs: [run])
      package = build_package_with_body_paragraphs(para)

      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      package.settings = settings

      described_class.new(package).reconcile

      expect(para.runs).to be_empty
    end

    it "removes dangling endnote references from body" do
      run = run_class.new(
        text: text_class.new(value: "text"),
        endnote_reference: en_ref_class.new(id: "99"),
      )
      para = para_class.new(runs: [run])
      package = build_package_with_body_paragraphs(para)

      settings = settings_class.new
      settings.endnote_pr = endnote_pr_class.new
      package.settings = settings

      described_class.new(package).reconcile

      expect(para.runs).to be_empty
    end

    it "preserves valid footnote references" do
      run = run_class.new(
        text: text_class.new(value: "text"),
        footnote_reference: fn_ref_class.new(id: "1"),
      )
      para = para_class.new(runs: [run])
      package = build_package_with_body_paragraphs(para)

      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: []),
        ],
      )
      package.settings = settings
      package.footnotes = footnotes

      described_class.new(package).reconcile

      expect(para.runs.size).to eq(1)
      expect(para.runs.first.footnote_reference.id).to eq("1")
    end

    it "removes dangling header references from sectPr" do
      sect_pr = sect_pr_class.new(
        page_size: page_size_class.new(width: 12_240, height: 15_840),
        header_references: [
          header_ref_class.new(type: "default", r_id: "rIdGhost"),
          header_ref_class.new(type: "first", r_id: "rIdValid"),
        ],
      )
      para = para_class.new(runs: [run_class.new(text: text_class.new(value: "x"))])
      package = build_package_with_body_paragraphs(para)
      package.document.body.section_properties = sect_pr
      package.document.header_footer_parts = [
        { r_id: "rIdValid", content: Uniword::Wordprocessingml::Header.new },
      ]

      described_class.new(package).reconcile

      refs = sect_pr.header_references
      expect(refs.size).to eq(1)
      expect(refs.first.r_id).to eq("rIdValid")
    end

    it "removes dangling footer references from sectPr" do
      sect_pr = sect_pr_class.new(
        page_size: page_size_class.new(width: 12_240, height: 15_840),
        footer_references: [
          footer_ref_class.new(type: "default", r_id: "rIdGhost"),
        ],
      )
      para = para_class.new(runs: [run_class.new(text: text_class.new(value: "x"))])
      package = build_package_with_body_paragraphs(para)
      package.document.body.section_properties = sect_pr
      package.document.header_footer_parts = [
        { r_id: "rIdReal", content: Uniword::Wordprocessingml::Footer.new },
      ]

      described_class.new(package).reconcile

      expect(sect_pr.footer_references).to be_empty
    end

    it "preserves valid header and footer references" do
      sect_pr = sect_pr_class.new(
        page_size: page_size_class.new(width: 12_240, height: 15_840),
        header_references: [
          header_ref_class.new(type: "default", r_id: "rId1"),
        ],
        footer_references: [
          footer_ref_class.new(type: "default", r_id: "rId2"),
        ],
      )
      para = para_class.new(runs: [run_class.new(text: text_class.new(value: "x"))])
      package = build_package_with_body_paragraphs(para)
      package.document.body.section_properties = sect_pr
      package.document.header_footer_parts = [
        { r_id: "rId1", content: Uniword::Wordprocessingml::Header.new },
        { r_id: "rId2", content: Uniword::Wordprocessingml::Footer.new },
      ]

      described_class.new(package).reconcile

      expect(sect_pr.header_references.size).to eq(1)
      expect(sect_pr.footer_references.size).to eq(1)
    end

    it "collects valid rIds from document_rels" do
      sect_pr = sect_pr_class.new(
        page_size: page_size_class.new(width: 12_240, height: 15_840),
        header_references: [
          header_ref_class.new(type: "default", r_id: "rId7"),
        ],
      )
      para = para_class.new(runs: [run_class.new(text: text_class.new(value: "x"))])
      package = build_package_with_body_paragraphs(para)
      package.document.body.section_properties = sect_pr
      package.document.header_footer_parts = []
      package.document_rels = Uniword::Docx::Package.minimal_document_rels
      package.document_rels.relationships <<
        Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId7",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header",
          target: "header1.xml",
        )

      described_class.new(package).reconcile

      expect(sect_pr.header_references.size).to eq(1)
    end
  end

  describe "style reference integrity" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:text_class) { Uniword::Wordprocessingml::Text }
    let(:para_class) { Uniword::Wordprocessingml::Paragraph }
    let(:style_ref_class) { Uniword::Properties::StyleReference }

    def build_package_with_style(style_val)
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      props = Uniword::Wordprocessingml::ParagraphProperties.new(
        style: style_ref_class.new(value: style_val),
      )
      para = para_class.new(
        properties: props,
        runs: [run_class.new(text: text_class.new(value: "text"))],
      )
      package.document.body.paragraphs << para
      package
    end

    it "preserves style reference when style exists in styles.xml" do
      package = build_package_with_style("Heading1")
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "Heading1",
        name: Uniword::Wordprocessingml::StyleName.new(val: "heading 1"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(package.document.body.paragraphs.first.properties.style.value)
        .to eq("Heading1")
    end

    it "removes style reference when style does not exist" do
      package = build_package_with_style("GhostStyle")
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "Normal",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Normal"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(package.document.body.paragraphs.first.properties.style).to be_nil
    end

    it "handles empty styles gracefully" do
      package = build_package_with_style("AnyStyle")
      package.styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )

      described_class.new(package).reconcile

      expect(package.document.body.paragraphs.first.properties.style).to be_nil
    end
  end

  describe "style inheritance integrity" do
    it "removes dangling basedOn reference" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(
          text: Uniword::Wordprocessingml::Text.new(value: "text"),
        )],
      )
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "MyStyle",
        name: Uniword::Wordprocessingml::StyleName.new(val: "My Style"),
        basedOn: Uniword::Wordprocessingml::BasedOn.new(val: "GhostParent"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(styles.styles.first.basedOn).to be_nil
    end

    it "removes dangling link reference" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(
          text: Uniword::Wordprocessingml::Text.new(value: "text"),
        )],
      )
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "MyStyle",
        name: Uniword::Wordprocessingml::StyleName.new(val: "My Style"),
        link: Uniword::Wordprocessingml::Link.new(val: "GhostCharStyle"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(styles.styles.first.link).to be_nil
    end

    it "preserves valid basedOn and link references" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [Uniword::Wordprocessingml::Run.new(
          text: Uniword::Wordprocessingml::Text.new(value: "text"),
        )],
      )
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "ParentStyle",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Parent"),
      ))
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "character", styleId: "LinkedChar",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Linked Char"),
      ))
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "paragraph", styleId: "ChildStyle",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Child"),
        basedOn: Uniword::Wordprocessingml::BasedOn.new(val: "ParentStyle"),
        link: Uniword::Wordprocessingml::Link.new(val: "LinkedChar"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      child = styles.styles.find { |s| s.id == "ChildStyle" }
      expect(child.basedOn.val).to eq("ParentStyle")
      expect(child.link.val).to eq("LinkedChar")
    end
  end

  describe "run and table style integrity" do
    it "removes dangling run style (rStyle) reference" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      run = Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(value: "styled"),
        properties: Uniword::Wordprocessingml::RunProperties.new(
          style: Uniword::Properties::RunStyleReference.new(value: "GhostChar"),
        ),
      )
      package.document.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [run],
      )
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "character", styleId: "Emphasis",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Emphasis"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(run.properties.style).to be_nil
    end

    it "removes dangling table style (tblStyle) reference" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      tbl = Uniword::Wordprocessingml::Table.new(
        properties: Uniword::Wordprocessingml::TableProperties.new(
          style: Uniword::Wordprocessingml::TableStyle.new(val: "GhostTable"),
        ),
        rows: [Uniword::Wordprocessingml::TableRow.new(
          cells: [Uniword::Wordprocessingml::TableCell.new(
            paragraphs: [Uniword::Wordprocessingml::Paragraph.new(
              runs: [Uniword::Wordprocessingml::Run.new(
                text: Uniword::Wordprocessingml::Text.new(value: "cell"),
              )],
            )],
          )],
        )],
      )
      package.document.body.tables << tbl
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "table", styleId: "TableNormal",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Normal Table"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(tbl.properties.style).to be_nil
    end

    it "preserves valid run and table style references" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      run = Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(value: "styled"),
        properties: Uniword::Wordprocessingml::RunProperties.new(
          style: Uniword::Properties::RunStyleReference.new(value: "Emphasis"),
        ),
      )
      package.document.body.paragraphs << Uniword::Wordprocessingml::Paragraph.new(
        runs: [run],
      )
      tbl = Uniword::Wordprocessingml::Table.new(
        properties: Uniword::Wordprocessingml::TableProperties.new(
          style: Uniword::Wordprocessingml::TableStyle.new(val: "TableNormal"),
        ),
        rows: [Uniword::Wordprocessingml::TableRow.new(
          cells: [Uniword::Wordprocessingml::TableCell.new(
            paragraphs: [Uniword::Wordprocessingml::Paragraph.new(
              runs: [Uniword::Wordprocessingml::Run.new(
                text: Uniword::Wordprocessingml::Text.new(value: "cell"),
              )],
            )],
          )],
        )],
      )
      package.document.body.tables << tbl
      styles = Uniword::Wordprocessingml::StylesConfiguration.new(
        include_defaults: false,
      )
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "character", styleId: "Emphasis",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Emphasis"),
      ))
      styles.add_style(Uniword::Wordprocessingml::Style.new(
        type: "table", styleId: "TableNormal",
        name: Uniword::Wordprocessingml::StyleName.new(val: "Normal Table"),
      ))
      package.styles = styles

      described_class.new(package).reconcile

      expect(run.properties.style.value).to eq("Emphasis")
      expect(tbl.properties.style.val).to eq("TableNormal")
    end
  end

  describe "numbering body reference integrity" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:text_class) { Uniword::Wordprocessingml::Text }
    let(:para_class) { Uniword::Wordprocessingml::Paragraph }

    def build_package_with_num_id(num_id)
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      num_pr = Uniword::Properties::NumberingProperties.new(
        num_id: Uniword::Properties::NumberingId.new(value: num_id),
      )
      props = Uniword::Wordprocessingml::ParagraphProperties.new(
        numbering_properties: num_pr,
      )
      para = para_class.new(
        properties: props,
        runs: [run_class.new(text: text_class.new(value: "item"))],
      )
      package.document.body.paragraphs << para
      package
    end

    it "preserves numbering reference when numId exists" do
      package = build_package_with_num_id(1)
      num_config = Uniword::Wordprocessingml::NumberingConfiguration.new
      num_config.add_instance(abstract_num_id: 0, num_id: 1)
      package.numbering = num_config

      described_class.new(package).reconcile

      num_pr = package.document.body.paragraphs.first.properties.numbering_properties
      expect(num_pr).not_to be_nil
    end

    it "removes numbering reference when numId does not exist" do
      package = build_package_with_num_id(99)
      num_config = Uniword::Wordprocessingml::NumberingConfiguration.new
      num_config.add_instance(abstract_num_id: 0, num_id: 1)
      package.numbering = num_config

      described_class.new(package).reconcile

      num_pr = package.document.body.paragraphs.first.properties.numbering_properties
      expect(num_pr).to be_nil
    end

    it "preserves numId=0 (no numbering marker)" do
      package = build_package_with_num_id(0)

      described_class.new(package).reconcile

      num_pr = package.document.body.paragraphs.first.properties.numbering_properties
      expect(num_pr).not_to be_nil
    end
  end

  describe "hyperlink reference integrity" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:text_class) { Uniword::Wordprocessingml::Text }
    let(:para_class) { Uniword::Wordprocessingml::Paragraph }
    let(:hyperlink_class) { Uniword::Wordprocessingml::Hyperlink }

    it "removes hyperlink with dangling rId" do
      hl = hyperlink_class.new(id: "rId99")
      hl.runs << run_class.new(text: text_class.new(value: "click"))
      para = para_class.new(
        hyperlinks: [hl],
        runs: [run_class.new(text: text_class.new(value: "text"))],
      )
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << para
      package.document_rels = Uniword::Docx::Package.minimal_document_rels

      described_class.new(package).reconcile

      expect(para.hyperlinks).to be_empty
    end

    it "preserves hyperlink with valid rId" do
      hl = hyperlink_class.new(id: "rId10")
      hl.runs << run_class.new(text: text_class.new(value: "click"))
      para = para_class.new(
        hyperlinks: [hl],
        runs: [run_class.new(text: text_class.new(value: "text"))],
      )
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << para
      package.document_rels = Uniword::Docx::Package.minimal_document_rels
      package.document_rels.relationships <<
        Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId10",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
          target: "http://example.com",
        )

      described_class.new(package).reconcile

      expect(para.hyperlinks.size).to eq(1)
    end

    it "preserves internal anchor hyperlinks without rId check" do
      hl = hyperlink_class.new(anchor: "bookmark1")
      hl.runs << run_class.new(text: text_class.new(value: "jump"))
      para = para_class.new(
        hyperlinks: [hl],
        runs: [run_class.new(text: text_class.new(value: "text"))],
      )
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << para

      described_class.new(package).reconcile

      expect(para.hyperlinks.size).to eq(1)
    end

    it "preserves non-rId hyperlinks (builder-generated URLs)" do
      hl = hyperlink_class.new(id: "https://example.com")
      hl.runs << run_class.new(text: text_class.new(value: "link"))
      para = para_class.new(
        hyperlinks: [hl],
        runs: [run_class.new(text: text_class.new(value: "text"))],
      )
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.paragraphs << para
      package.document_rels = Uniword::Docx::Package.minimal_document_rels

      described_class.new(package).reconcile

      expect(para.hyperlinks.size).to eq(1)
    end
  end

  describe "paraId uniqueness" do
    it "deduplicates colliding paraIds" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new

      p1 = Uniword::Wordprocessingml::Paragraph.new(para_id: "DEADBEEF")
      p1.runs << Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(value: "first"),
      )
      p2 = Uniword::Wordprocessingml::Paragraph.new(para_id: "DEADBEEF")
      p2.runs << Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(value: "second"),
      )
      package.document.body.paragraphs << p1
      package.document.body.paragraphs << p2

      described_class.new(package).reconcile

      ids = package.document.body.paragraphs.map(&:para_id)
      expect(ids.uniq.size).to eq(ids.size)
    end
  end

  describe "rId uniqueness" do
    it "deduplicates colliding rIds in document_rels" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      para.runs << Uniword::Wordprocessingml::Run.new(
        text: Uniword::Wordprocessingml::Text.new(value: "x"),
      )
      package.document.body.paragraphs << para
      package.document_rels = Uniword::Docx::Package.minimal_document_rels

      # Inject a duplicate rId1
      package.document_rels.relationships <<
        Uniword::Ooxml::Relationships::Relationship.new(
          id: "rId1",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
          target: "media/image1.png",
        )

      described_class.new(package).reconcile

      ids = package.document_rels.relationships.map(&:id)
      expect(ids.uniq.size).to eq(ids.size)
    end
  end

  describe "numbering reconciliation" do
    let(:profile) { Uniword::Docx::Profile.load(:word_2024_en) }
    let(:num_config_class) { Uniword::Wordprocessingml::NumberingConfiguration }
    let(:num_inst_class) { Uniword::Wordprocessingml::NumberingInstance }
    let(:abstract_num_id_class) { Uniword::Wordprocessingml::AbstractNumId }

    def build_package_with_numbering
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      run.text = Uniword::Wordprocessingml::Text.new(value: "Item")
      para.runs << run
      package.document.body.paragraphs << para
      package
    end

    it "generates durableId for instances missing one" do
      package = build_package_with_numbering
      num_config = num_config_class.new
      num_config.add_instance(abstract_num_id: 0, num_id: 1)
      package.numbering = num_config

      described_class.new(package, profile: profile).reconcile

      inst = package.numbering.instances.first
      expect(inst.durable_id).not_to be_nil
      expect(inst.durable_id.to_s).to match(/^-?\d+$/)
    end

    it "does not overwrite existing durableId" do
      package = build_package_with_numbering
      num_config = num_config_class.new
      inst = num_config.add_instance(abstract_num_id: 0, num_id: 1)
      inst.durable_id = "42"
      package.numbering = num_config

      described_class.new(package, profile: profile).reconcile

      expect(package.numbering.instances.first.durable_id.to_s).to eq("42")
    end

    it "handles signed 32-bit overflow for durableId" do
      package = build_package_with_numbering
      num_config = num_config_class.new
      # Create several instances to trigger deterministic ID generation
      5.times do |i|
        num_config.add_instance(abstract_num_id: i, num_id: i + 1)
      end
      package.numbering = num_config

      described_class.new(package, profile: profile).reconcile

      package.numbering.instances.each do |inst|
        raw = inst.durable_id.to_i
        expect(raw).to be >= -2_147_483_648
        expect(raw).to be <= 2_147_483_647
      end
    end
  end

  describe "table gridAfter reconciliation" do
    let(:table_class) { Uniword::Wordprocessingml::Table }
    let(:row_class) { Uniword::Wordprocessingml::TableRow }
    let(:cell_class) { Uniword::Wordprocessingml::TableCell }
    let(:grid_col_class) { Uniword::Wordprocessingml::GridCol }
    let(:grid_class) { Uniword::Wordprocessingml::TableGrid }
    let(:row_props_class) { Uniword::Wordprocessingml::TableRowProperties }

    def build_package_with_table(table)
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.body.tables << table
      package
    end

    it "adds gridAfter when row covers fewer columns than grid" do
      row_full = row_class.new(cells: [cell_class.new, cell_class.new, cell_class.new])
      row_short = row_class.new(cells: [cell_class.new, cell_class.new])
      table = table_class.new(rows: [row_full, row_short])
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      # row_full covers 3 cols (no gridAfter); row_short covers 2 cols (gridAfter=1)
      expect(row_full.properties&.grid_after).to be_nil
      expect(row_short.properties).not_to be_nil
      expect(row_short.properties.grid_after).not_to be_nil
      expect(row_short.properties.grid_after.value).to eq(1)
    end

    it "does not add gridAfter when row covers all grid columns" do
      row = row_class.new(cells: [cell_class.new, cell_class.new, cell_class.new])
      table = table_class.new(rows: [row])
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      expect(row.properties&.grid_after).to be_nil
    end

    it "accounts for gridSpan when calculating gridAfter" do
      # Row 1: 3 cells, covers 3 cols
      row_full = row_class.new(cells: [cell_class.new, cell_class.new, cell_class.new])
      # Row 2: 1 cell with gridSpan=2, covers 2 out of 3 → gridAfter=1
      tc_pr = Uniword::Wordprocessingml::TableCellProperties.new(
        grid_span: Uniword::Wordprocessingml::ValInt.new(value: 2),
      )
      span_cell = cell_class.new
      span_cell.properties = tc_pr
      row_span = row_class.new(cells: [span_cell])
      table = table_class.new(rows: [row_full, row_span])
      package = build_package_with_table(table)

      described_class.new(package).reconcile

      expect(row_span.properties.grid_after.value).to eq(1)
    end
  end

  describe "existing value preservation (||= pattern)" do
    let(:profile) { Uniword::Docx::Profile.load(:word_2024_en) }

    it "preserves pre-existing rsidR on paragraphs" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new(
        rsid_r: "AABBCCDD",
        rsid_r_default: "11223344",
        para_id: "DEADBEEF",
        text_id: "CAFEBABE",
      )
      run = Uniword::Wordprocessingml::Run.new
      run.text = Uniword::Wordprocessingml::Text.new(value: "Hello")
      para.runs << run
      package.document.body.paragraphs << para

      described_class.new(package, profile: profile).reconcile

      expect(para.rsid_r).to eq("AABBCCDD")
      expect(para.rsid_r_default).to eq("11223344")
      expect(para.para_id).to eq("DEADBEEF")
      expect(para.text_id).to eq("CAFEBABE")
    end

    it "preserves pre-existing section properties rsidR" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new
      run.text = Uniword::Wordprocessingml::Text.new(value: "Hello")
      para.runs << run
      package.document.body.paragraphs << para
      package.document.body.section_properties =
        Uniword::Wordprocessingml::SectionProperties.new(
          rsid_r: "FFEEDDCC",
          page_size: Uniword::Wordprocessingml::PageSize.new(
            width: 12_240, height: 15_840
          ),
        )

      described_class.new(package, profile: profile).reconcile

      expect(package.document.body.section_properties.rsid_r).to eq("FFEEDDCC")
    end
  end

  describe "notes: reorder by reference order" do
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:text_class) { Uniword::Wordprocessingml::Text }
    let(:para_class) { Uniword::Wordprocessingml::Paragraph }
    let(:fn_ref_class) { Uniword::Wordprocessingml::FootnoteReference }

    it "reorders footnotes to match body reference order" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new

      # Paragraph references footnote 2 first, then 1
      run2 = run_class.new(
        text: text_class.new(value: "text2"),
        footnote_reference: fn_ref_class.new(id: "2"),
      )
      run1 = run_class.new(
        text: text_class.new(value: "text1"),
        footnote_reference: fn_ref_class.new(id: "1"),
      )
      para = para_class.new(runs: [run2, run1])
      package.document.body.paragraphs << para

      settings = settings_class.new
      settings.footnote_pr = footnote_pr_class.new
      package.settings = settings

      # Footnotes stored in order 1, 2 (wrong order relative to body)
      footnotes = footnotes_class.new(
        footnote_entries: [
          footnote_class.new(id: "-1", type: "separator", paragraphs: []),
          footnote_class.new(id: "0", type: "continuationSeparator", paragraphs: []),
          footnote_class.new(id: "1", paragraphs: [para_class.new(runs: [run_class.new(text: text_class.new(value: "fn1"))])]),
          footnote_class.new(id: "2", paragraphs: [para_class.new(runs: [run_class.new(text: text_class.new(value: "fn2"))])]),
        ],
      )
      package.footnotes = footnotes

      described_class.new(package).reconcile

      user_entries = footnotes.footnote_entries.reject { |e| %w[separator continuationSeparator footnoteSeparator continuationNotice].include?(e.type) }
      expect(user_entries.map(&:id)).to eq(%w[1 2])
    end
  end

  describe "headers/footers reconciliation" do
    let(:header_class) { Uniword::Wordprocessingml::Header }
    let(:footer_class) { Uniword::Wordprocessingml::Footer }
    let(:run_class) { Uniword::Wordprocessingml::Run }
    let(:run_props_class) { Uniword::Wordprocessingml::RunProperties }
    let(:text_class) { Uniword::Wordprocessingml::Text }

    def build_package_with_headers
      package = Uniword::Docx::Package.new
      header = header_class.new
      para = Uniword::Wordprocessingml::Paragraph.new
      props = Uniword::Wordprocessingml::ParagraphProperties.new
      props.alignment = Uniword::Properties::Alignment.new(val: "right")
      para.properties = props

      run = run_class.new
      run.properties = run_props_class.new
      para.runs << run

      header.paragraphs << para
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document.headers = { "default" => header }
      package
    end

    it "strips empty runs from header paragraphs" do
      package = build_package_with_headers
      described_class.new(package).reconcile

      header = package.document.headers["default"]
      expect(header.paragraphs.first.runs).to be_empty
    end

    it "preserves runs that have text content" do
      package = build_package_with_headers
      run = run_class.new
      run.text = text_class.new(content: "Header text")
      package.document.headers["default"].paragraphs.first.runs << run

      described_class.new(package).reconcile

      header = package.document.headers["default"]
      expect(header.paragraphs.first.runs.size).to eq(1)
