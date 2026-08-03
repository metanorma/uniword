# frozen_string_literal: true

require "spec_helper"
require "uniword/docx"

RSpec.describe Uniword::Docx::Reconciler do
  let(:settings_class) { Uniword::Wordprocessingml::Settings }

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
end
