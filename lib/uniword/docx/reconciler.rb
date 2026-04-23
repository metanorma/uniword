# frozen_string_literal: true

require "yaml"
require "securerandom"

module Uniword
  module Docx
    # Reconciles DOCX-level invariants before serialization.
    #
    # Ensures that the document's model state is internally consistent so that
    # the serialized output is always a valid DOCX file. Called from
    # Docx::Package#to_zip_content before the serialization phase.
    #
    # This is not an extension point -- it enforces built-in invariants.
    # For customizable validation, use Uniword::Validation::Rules instead.
    # For user-defined requirements, use Docx::Requirement (future).
    class Reconciler
      CONFIG_DIR = File.join(__dir__, "../../../config")

      def initialize(package, profile: nil)
        @package = package
        @profile = profile
      end

      def reconcile
        # Group 1: Document body (always)
        reconcile_section_properties
        reconcile_footnotes
        reconcile_endnotes

        # Group 2: Support parts (profile-dependent)
        if @profile
          reconcile_theme
          reconcile_settings
          reconcile_font_table
          reconcile_styles
          reconcile_web_settings
          reconcile_app_properties
          reconcile_core_properties
          reconcile_document_body
        end

        # Group 3: Package consistency (always)
        reconcile_content_types
        reconcile_package_rels
        reconcile_document_rels
      end

      private

      attr_reader :package, :profile

      # -- Section Properties --

      def reconcile_section_properties
        return unless package.document&.body

        body = package.document.body
        return if body.section_properties

        body.section_properties = Wordprocessingml::SectionProperties.new(
          page_size: Wordprocessingml::PageSize.new(width: 12_240, height: 15_840),
          page_margins: Wordprocessingml::PageMargins.new(
            top: 1440, right: 1440, bottom: 1440, left: 1440,
            header: 720, footer: 720, gutter: 0
          ),
          columns: Wordprocessingml::Columns.new(space: 720),
          doc_grid: Wordprocessingml::DocGrid.new(line_pitch: 360)
        )
      end

      # -- Footnotes --

      def reconcile_footnotes
        has_fn_pr = package.settings&.footnote_pr
        has_footnotes = package.footnotes

        if has_fn_pr && !has_footnotes
          package.footnotes = minimal_footnotes
        elsif has_footnotes && !has_fn_pr
          package.settings ||= Wordprocessingml::Settings.new
          package.settings.footnote_pr = Wordprocessingml::FootnotePr.new
        end

        ensure_separators(package.footnotes, :footnote) if package.footnotes
      end

      # -- Endnotes --

      def reconcile_endnotes
        has_en_pr = package.settings&.endnote_pr
        has_endnotes = package.endnotes

        if has_en_pr && !has_endnotes
          package.endnotes = minimal_endnotes
        elsif has_endnotes && !has_en_pr
          package.settings ||= Wordprocessingml::Settings.new
          package.settings.endnote_pr = Wordprocessingml::EndnotePr.new
        end

        ensure_separators(package.endnotes, :endnote) if package.endnotes
      end

      # -- Builders --

      def minimal_footnotes
        Wordprocessingml::Footnotes.new(
          footnote_entries: [separator_entry(:footnote), continuation_entry(:footnote)]
        )
      end

      def minimal_endnotes
        Wordprocessingml::Endnotes.new(
          endnote_entries: [separator_entry(:endnote), continuation_entry(:endnote)]
        )
      end

      def separator_entry(type)
        entry_class(type).new(
          id: "-1", type: "separator",
          paragraphs: [Wordprocessingml::Paragraph.new]
        )
      end

      def continuation_entry(type)
        entry_class(type).new(
          id: "0", type: "continuationSeparator",
          paragraphs: [Wordprocessingml::Paragraph.new]
        )
      end

      def entry_class(type)
        type == :footnote ? Wordprocessingml::Footnote : Wordprocessingml::Endnote
      end

      def ensure_separators(notes, type)
        entries = notes.public_send(:"#{type}_entries")
        ids = entries.map(&:id).to_set

        entries.unshift(separator_entry(type)) unless ids.include?("-1")
        entries.unshift(continuation_entry(type)) unless ids.include?("0")
      end

      # -- Group 2: Support parts (profile-dependent) --

      def reconcile_theme
        return unless profile
        return if package.theme

        theme_name = profile.system.default_theme_name
        return unless theme_name

        begin
          friendly = Themes::Theme.load(theme_name)
          package.theme = friendly.to_word_theme
        rescue ArgumentError
          nil
        end
      end

      def reconcile_settings
        return unless profile

        settings = package.settings
        settings ||= begin
          package.settings = Wordprocessingml::Settings.new
          package.settings
        end

        rsid = generate_rsid

        settings.zoom ||= Wordprocessingml::Zoom.new(percent: 100)
        settings.proof_state ||= Wordprocessingml::ProofState.new(
          spelling: "clean", grammar: "clean"
        )
        settings.default_tab_stop ||= Wordprocessingml::DefaultTabStop.new(val: "720")
        settings.character_spacing_control ||= Wordprocessingml::CharacterSpacingControl.new(
          val: "doNotCompress"
        )

        settings.compat ||= build_compat
        settings.rsids ||= build_rsids(rsid)
        settings.math_pr ||= build_math_pr
        settings.theme_font_lang ||= Wordprocessingml::ThemeFontLang.new(
          val: profile.lang,
          east_asia: profile.east_asia_lang
        )
        settings.clr_scheme_mapping ||= build_clr_scheme_mapping
        settings.decimal_symbol ||= Wordprocessingml::DecimalSymbol.new(
          val: profile.decimal_symbol
        )
        settings.list_separator ||= Wordprocessingml::ListSeparator.new(
          val: profile.list_separator
        )

        settings.w14_doc_id ||= Wordprocessingml::W14DocId.new(
          val: "{#{SecureRandom.uuid.upcase}}"
        )
        settings.w15_chart_tracking_ref_based ||= Wordprocessingml::W15ChartTrackingRefBased.new
        settings.w15_doc_id ||= Wordprocessingml::W15DocId.new(
          val: "{#{SecureRandom.uuid.upcase}}"
        )

        settings.mc_ignorable ||= Ooxml::Types::McIgnorable.new(
          "w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du"
        )
      end

      def reconcile_font_table
        return unless profile

        font_table = package.font_table
        font_table ||= begin
          package.font_table = Wordprocessingml::FontTable.new
          package.font_table
        end

        return unless font_table.fonts.empty?

        metadata = load_font_metadata
        return unless metadata

        font_names = font_names_for_profile
        font_names.each do |name|
          meta = metadata[name]
          next unless meta

          sig_data = meta["sig"] || {}
          font = Wordprocessingml::Font.new(
            name: name,
            panose1: Wordprocessingml::Panose1.new(val: meta["panose1"]),
            charset: Wordprocessingml::Charset.new(val: meta["charset"]),
            family: Wordprocessingml::Family.new(val: meta["family"]),
            pitch: Wordprocessingml::Pitch.new(val: meta["pitch"]),
            sig: Wordprocessingml::Sig.new(
              usb0: sig_data["usb0"], usb1: sig_data["usb1"],
              usb2: sig_data["usb2"], usb3: sig_data["usb3"],
              csb0: sig_data["csb0"], csb1: sig_data["csb1"]
            )
          )

          font.alt_name = Wordprocessingml::AltName.new(val: meta["alt_name"]) if meta["alt_name"]
          font_table.fonts << font
        end

        font_table.mc_ignorable ||= Ooxml::Types::McIgnorable.new(
          "w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du"
        )
      end

      def reconcile_styles
        return unless profile

        styles = package.styles
        styles ||= begin
          package.styles = Wordprocessingml::StylesConfiguration.new(include_defaults: false)
          package.styles
        end

        styles.doc_defaults ||= build_doc_defaults
        styles.latent_styles ||= build_latent_styles

        ensure_default_styles(styles)

        styles.mc_ignorable ||= Ooxml::Types::McIgnorable.new(
          "w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du"
        )
      end

      def reconcile_web_settings
        return unless profile

        ws = package.web_settings
        ws ||= begin
          package.web_settings = Wordprocessingml::WebSettings.new
          package.web_settings
        end

        ws.optimize_for_browser ||= Wordprocessingml::OptimizeForBrowser.new
        ws.allow_png ||= Wordprocessingml::AllowPng.new
        ws.mc_ignorable ||= Ooxml::Types::McIgnorable.new(
          "w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du"
        )
      end

      def reconcile_app_properties
        return unless profile

        app = package.app_properties
        app ||= begin
          package.app_properties = Ooxml::AppProperties.new
          package.app_properties
        end

        app.template ||= "Normal.dotm"
        app.application = profile.application_name
        app.app_version = profile.app_version
        app.company = profile.user_company if profile.user_company && !profile.user_company.empty?
      end

      def reconcile_core_properties
        return unless profile

        # Rebuild from parsed state to ensure namespace_scope
        # declarations (e.g. xmlns:dcmitype) are applied on
        # serialization (lutaml-model preserves parsed namespaces)
        old_cp = package.core_properties
        if old_cp
          package.core_properties = Ooxml::CoreProperties.new(
            title: old_cp.title,
            subject: old_cp.subject,
            creator: old_cp.creator,
            keywords: old_cp.keywords,
            description: old_cp.description,
            last_modified_by: old_cp.last_modified_by,
            revision: old_cp.revision,
            created: old_cp.created,
            modified: old_cp.modified
          )
        else
          package.core_properties = Ooxml::CoreProperties.new
        end
        cp = package.core_properties

        if profile.user_name && !profile.user_name.empty?
          cp.last_modified_by = profile.user_name
          cp.creator ||= profile.user_name
        end

        now = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
        cp.modified = Ooxml::Types::DctermsModifiedType.new(
          value: now, type: "dcterms:W3CDTF"
        )
        cp.created ||= Ooxml::Types::DctermsCreatedType.new(
          value: now, type: "dcterms:W3CDTF"
        )

        cp.revision = "1" unless cp.revision
      end

      def reconcile_document_body
        return unless profile
        return unless package.document&.body

        doc = package.document
        doc.mc_ignorable ||= Ooxml::Types::McIgnorable.new(
          "w14 w15 wp14"
        )

        rsid = generate_rsid
        body = doc.body

        body.paragraphs.each do |para|
          para.rsid_r ||= rsid
          para.rsid_r_default ||= "00000000"
          para.para_id ||= generate_hex_id
          para.text_id ||= "77777777"
        end

        sect_pr = body.section_properties
        return unless sect_pr

        sect_pr.rsid_r ||= rsid
      end

      # -- Group 3: Package consistency (always) --

      def reconcile_content_types
        ct = package.content_types
        return unless ct

        # Defaults: only rels + xml (image types added by inject_image_parts)
        ct.defaults = [
          Uniword::ContentTypes::Default.new(
            extension: "rels",
            content_type: "application/vnd.openxmlformats-package.relationships+xml"
          ),
          Uniword::ContentTypes::Default.new(
            extension: "xml",
            content_type: "application/xml"
          )
        ]

        # Overrides: rebuild for standard parts that exist
        standard = content_type_overrides_for_present_parts
        standard_parts = standard.map(&:part_name).to_set
        non_standard = ct.overrides.reject do |o|
          standard_parts.include?(o.part_name)
        end

        ct.overrides = standard + non_standard
      end

      def reconcile_package_rels
        rels = package.package_rels
        return unless rels

        base = "http://schemas.openxmlformats.org"
        standard = [
          build_rel("rId1",
                    "#{base}/officeDocument/2006/relationships/officeDocument",
                    "word/document.xml"),
          build_rel("rId2",
                    "#{base}/package/2006/relationships/metadata/core-properties",
                    "docProps/core.xml"),
          build_rel("rId3",
                    "#{base}/officeDocument/2006/relationships/extended-properties",
                    "docProps/app.xml")
        ]

        standard_targets = standard.map(&:target).to_set
        non_standard = rels.relationships.reject do |r|
          standard_targets.include?(r.target)
        end

        rels.relationships = standard + non_standard
      end

      def reconcile_document_rels
        rels = package.document_rels
        return unless rels

        base = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
        defs = [
          ["rId1", "styles", "styles.xml", package.styles],
          ["rId2", "settings", "settings.xml", package.settings],
          ["rId3", "webSettings", "webSettings.xml", package.web_settings],
          ["rId4", "fontTable", "fontTable.xml", package.font_table],
          ["rId5", "theme", "theme/theme1.xml", package.theme]
        ]

        standard = defs.filter_map do |rid, suffix, target, obj|
          next unless obj

          build_rel(rid, "#{base}/#{suffix}", target)
        end

        standard_targets = standard.map(&:target).to_set
        non_standard = rels.relationships.reject do |r|
          standard_targets.include?(r.target)
        end

        rels.relationships = standard + non_standard
      end

      # -- Helpers --

      def generate_rsid
        "00#{SecureRandom.hex(3).upcase}"
      end

      def generate_hex_id
        SecureRandom.hex(4).upcase
      end

      def content_type_overrides_for_present_parts
        checks = [
          [package.document, "/word/document.xml",
           "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"],
          [package.styles, "/word/styles.xml",
           "application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"],
          [package.settings, "/word/settings.xml",
           "application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"],
          [package.font_table, "/word/fontTable.xml",
           "application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml"],
          [package.web_settings, "/word/webSettings.xml",
           "application/vnd.openxmlformats-officedocument.wordprocessingml.webSettings+xml"],
          [package.theme, "/word/theme/theme1.xml",
           "application/vnd.openxmlformats-officedocument.theme+xml"],
          [package.core_properties, "/docProps/core.xml",
           "application/vnd.openxmlformats-package.core-properties+xml"],
          [package.app_properties, "/docProps/app.xml",
           "application/vnd.openxmlformats-officedocument.extended-properties+xml"],
          [package.footnotes, "/word/footnotes.xml",
           "application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml"],
          [package.endnotes, "/word/endnotes.xml",
           "application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml"],
          [package.numbering, "/word/numbering.xml",
           "application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"]
        ]

        checks.filter_map do |obj, part_name, content_type|
          next unless obj

          Uniword::ContentTypes::Override.new(
            part_name: part_name,
            content_type: content_type
          )
        end
      end

      def build_rel(id, type, target)
        Ooxml::Relationships::Relationship.new(
          id: id, type: type, target: target
        )
      end

      def build_compat
        Wordprocessingml::Compat.new(
          compatSetting: [
            Wordprocessingml::CompatSetting.new(
              name: "compatibilityMode",
              uri: "http://schemas.microsoft.com/office/word",
              val: profile.compat_mode
            ),
            Wordprocessingml::CompatSetting.new(
              name: "overrideTableStyleFontSizeAndJustification",
              uri: "http://schemas.microsoft.com/office/word",
              val: "1"
            ),
            Wordprocessingml::CompatSetting.new(
              name: "enableOpenTypeFeatures",
              uri: "http://schemas.microsoft.com/office/word",
              val: "1"
            ),
            Wordprocessingml::CompatSetting.new(
              name: "doNotFlipMirrorIndents",
              uri: "http://schemas.microsoft.com/office/word",
              val: "1"
            ),
            Wordprocessingml::CompatSetting.new(
              name: "differentiateMultirowTableHeaders",
              uri: "http://schemas.microsoft.com/office/word",
              val: "1"
            ),
            Wordprocessingml::CompatSetting.new(
              name: "useWord2013TrackBottomHyphenation",
              uri: "http://schemas.microsoft.com/office/word",
              val: "1"
            )
          ]
        )
      end

      def build_rsids(rsid)
        root = "00#{SecureRandom.hex(3).upcase}"
        Wordprocessingml::Rsids.new(
          rsid_root: Wordprocessingml::RsidRoot.new(val: root),
          rsid: [Wordprocessingml::Rsid.new(val: rsid)]
        )
      end

      def build_math_pr
        Wordprocessingml::MathPr.new(
          math_font: Wordprocessingml::MathFont.new(val: "Cambria Math"),
          brk_bin: Wordprocessingml::BrkBin.new(val: "before"),
          brk_bin_sub: Wordprocessingml::BrkBinSub.new(val: "--"),
          small_frac: Wordprocessingml::SmallFrac.new(val: "0"),
          disp_def: Wordprocessingml::DispDef.new,
          l_margin: Wordprocessingml::LMargin.new(val: "1440"),
          r_margin: Wordprocessingml::RMargin.new(val: "1440"),
          def_jc: Wordprocessingml::DefJc.new(val: "centerGroup"),
          wrap_indent: Wordprocessingml::WrapIndent.new(val: "1440"),
          int_lim: Wordprocessingml::IntLim.new(val: "subSup"),
          nary_lim: Wordprocessingml::NaryLim.new(val: "undOvr")
        )
      end

      def build_clr_scheme_mapping
        Wordprocessingml::ClrSchemeMapping.new(
          bg1: "light1", t1: "dark1", bg2: "light2", t2: "dark2",
          accent1: "accent1", accent2: "accent2", accent3: "accent3",
          accent4: "accent4", accent5: "accent5", accent6: "accent6",
          hyperlink: "hyperlink", followed_hyperlink: "followedHyperlink"
        )
      end

      def build_doc_defaults
        r_pr = Wordprocessingml::RunProperties.new(
          fonts: Properties::RunFonts.new(
            ascii_theme: "minorHAnsi",
            east_asia_theme: "minorEastAsia",
            h_ansi_theme: "minorHAnsi",
            cs_theme: "minorBidi"
          ),
          kerning: Properties::Kerning.new(val: 2),
          size: Properties::FontSize.new(val: 24),
          size_cs: Properties::FontSize.new(val: 24),
          language: Properties::Language.new(
            val: profile.lang,
            east_asia: profile.east_asia_lang,
            bidi: profile.bidi_lang
          )
        )

        p_pr = Wordprocessingml::ParagraphProperties.new(
          spacing: Properties::Spacing.new(after: 160, line: 278, line_rule: "auto")
        )

        Wordprocessingml::DocDefaults.new(
          rPrDefault: Wordprocessingml::RPrDefault.new(rPr: r_pr),
          pPrDefault: Wordprocessingml::PPrDefault.new(pPr: p_pr)
        )
      end

      def build_latent_styles
        config = load_latent_styles_config
        return Wordprocessingml::LatentStyles.new(count: 0) unless config

        exceptions = (config["exceptions"] || []).map do |ex|
          attrs = { name: ex["name"] }
          attrs[:ui_priority] = ex["uiPriority"].to_i if ex["uiPriority"]
          attrs[:q_format] = ex["qFormat"] if ex["qFormat"]
          attrs[:semi_hidden] = ex["semiHidden"] if ex["semiHidden"]
          attrs[:unhide_when_used] = ex["unhideWhenUsed"] if ex["unhideWhenUsed"]
          attrs[:locked] = ex["locked"] if ex["locked"]
          Wordprocessingml::LatentStylesException.new(attrs)
        end

        Wordprocessingml::LatentStyles.new(
          def_locked_state: config["defLockedState"],
          def_ui_priority: config["defUIPriority"].to_i,
          def_semi_hidden: config["defSemiHidden"],
          def_unhide_when_used: config["defUnhideWhenUsed"],
          def_q_format: config["defQFormat"],
          count: config["count"].to_i,
          lsd_exception: exceptions
        )
      end

      def ensure_default_styles(styles)
        style_ids = styles.styles.map(&:id).to_set

        unless style_ids.include?("Normal")
          styles.add_style(Wordprocessingml::Style.new(
                             type: "paragraph", default: true, styleId: "Normal",
                             name: Wordprocessingml::StyleName.new(val: "Normal"),
                             qFormat: Properties::QuickFormat.new
                           ))
        end

        unless style_ids.include?("DefaultParagraphFont")
          styles.add_style(Wordprocessingml::Style.new(
                             type: "character", default: true, styleId: "DefaultParagraphFont",
                             name: Wordprocessingml::StyleName.new(val: "Default Paragraph Font"),
                             uiPriority: Wordprocessingml::UiPriority.new(val: 1),
                             semiHidden: Wordprocessingml::SemiHidden.new,
                             unhideWhenUsed: Wordprocessingml::UnhideWhenUsed.new
                           ))
        end

        unless style_ids.include?("TableNormal")
          tbl_pr = Wordprocessingml::TableProperties.new(
            table_indent: Properties::TableIndent.new(value: 0, type: "dxa"),
            table_cell_margin: Properties::TableCellMargin.new(
              top: Properties::Margin.new(w: 0, type: "dxa"),
              left: Properties::Margin.new(w: 108, type: "dxa"),
              bottom: Properties::Margin.new(w: 0, type: "dxa"),
              right: Properties::Margin.new(w: 108, type: "dxa")
            )
          )

          styles.add_style(Wordprocessingml::Style.new(
                             type: "table", default: true, styleId: "TableNormal",
                             name: Wordprocessingml::StyleName.new(val: "Normal Table"),
                             uiPriority: Wordprocessingml::UiPriority.new(val: 99),
                             semiHidden: Wordprocessingml::SemiHidden.new,
                             unhideWhenUsed: Wordprocessingml::UnhideWhenUsed.new,
                             tblPr: tbl_pr
                           ))
        end

        return if style_ids.include?("NoList")

        styles.add_style(Wordprocessingml::Style.new(
                           type: "numbering", default: true, styleId: "NoList",
                           name: Wordprocessingml::StyleName.new(val: "No List"),
                           uiPriority: Wordprocessingml::UiPriority.new(val: 99),
                           semiHidden: Wordprocessingml::SemiHidden.new,
                           unhideWhenUsed: Wordprocessingml::UnhideWhenUsed.new
                         ))
      end

      def load_font_metadata
        path = File.join(CONFIG_DIR, "font_metadata.yml")
        YAML.load_file(path)["fonts"]
      rescue StandardError
        nil
      end

      def load_latent_styles_config
        path = File.join(CONFIG_DIR, "latent_styles.yml")
        YAML.load_file(path)
      rescue StandardError
        nil
      end

      def font_names_for_profile
        names = []
        fs = profile.system.font_scheme
        names << fs&.minor_font if fs&.minor_font
        names << fs&.major_font if fs&.major_font

        loc = profile.locale
        names << loc.east_asian_font if loc.respond_to?(:east_asian_font) && loc.east_asian_font
        names << loc.east_asian_light_font if loc.respond_to?(:east_asian_light_font) && loc.east_asian_light_font

        names << "Times New Roman"
        names.uniq
      end
    end
  end
end
