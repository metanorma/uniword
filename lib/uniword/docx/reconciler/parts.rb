# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # Profile-dependent support parts reconciliation.
      #
      # Populates settings, font table, styles, numbering, web settings,
      # and document/app/core properties with profile-appropriate defaults.
      # Only runs when a profile is provided.
      module Parts
        def reconcile_settings
          return unless profile

          new_settings = package.settings.nil?
          settings = package.settings
          settings ||= begin
            package.settings = Wordprocessingml::Settings.new
            package.settings
          end

          rsid = generate_rsid

          settings.zoom ||= Wordprocessingml::Zoom.new(percent: 100)
          if new_settings && settings.do_not_display_page_boundaries.nil?
            settings.do_not_display_page_boundaries =
              Wordprocessingml::DoNotDisplayPageBoundaries.new
            ensure_element_in_order(settings, "doNotDisplayPageBoundaries",
                                    after: "zoom")
          end
          settings.proof_state ||= Wordprocessingml::ProofState.new(
            spelling: "clean", grammar: "clean",
          )
          settings.default_tab_stop ||= Wordprocessingml::DefaultTabStop.new(val: "720")
          settings.character_spacing_control ||=
            Wordprocessingml::CharacterSpacingControl.new(val: "doNotCompress")

          settings.compat ||= build_compat
          settings.rsids ||= build_rsids(rsid)
          settings.math_pr ||= build_math_pr
          settings.theme_font_lang ||= Wordprocessingml::ThemeFontLang.new(
            val: profile.lang,
            east_asia: profile.east_asia_lang,
          )
          settings.clr_scheme_mapping ||= build_clr_scheme_mapping
          settings.decimal_symbol ||= Wordprocessingml::DecimalSymbol.new(
            val: profile.decimal_symbol,
          )
          settings.list_separator ||= Wordprocessingml::ListSeparator.new(
            val: profile.list_separator,
          )

          unless settings.w14_doc_id
            settings.w14_doc_id = Wordprocessingml::W14DocId.new(
              val: hex_derive("w14_doc_id", 4),
            )
            record_fix(FixCodes::DOC_ID_GENERATED, "Generated w14:docId")
          end
          unless settings.w15_doc_id
            raw = hex_derive("w15_doc_id", 16)
            formatted = "#{raw[0..7]}-#{raw[8..11]}-#{raw[12..15]}-" \
                        "#{raw[16..19]}-#{raw[20..31]}"
            settings.w15_doc_id = Wordprocessingml::W15DocId.new(
              val: "{#{formatted.upcase}}",
            )
            record_fix(FixCodes::DOC_ID_GENERATED, "Generated w15:docId in GUID format")
          end

          set_mc_ignorable(settings)
        end

        def reconcile_font_table
          return unless profile

          font_table = package.font_table
          font_table ||= begin
            package.font_table = Wordprocessingml::FontTable.new
            record_fix(FixCodes::FONT_TABLE_CREATED, "Created font table")
            package.font_table
          end

          set_mc_ignorable(font_table)

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
            )

            if sig_data["usb0"] || sig_data["csb0"]
              font.sig = Wordprocessingml::Sig.new(
                usb0: sig_data["usb0"], usb1: sig_data["usb1"],
                usb2: sig_data["usb2"], usb3: sig_data["usb3"],
                csb0: sig_data["csb0"], csb1: sig_data["csb1"]
              )
            end

            font.alt_name = Wordprocessingml::AltName.new(val: meta["alt_name"]) if meta["alt_name"]
            font_table.fonts << font
          end

          set_mc_ignorable(font_table)
          record_fix(FixCodes::FONT_TABLE_CREATED,
                     "Populated font table with profile fonts and signatures")
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

          set_mc_ignorable(styles)
          record_fix(FixCodes::STYLE_DEFAULTS_ADDED,
                     "Ensured styles have docDefaults, latentStyles, and default styles")
        end

        def reconcile_numbering
          return unless profile
          return unless package.numbering

          set_mc_ignorable(package.numbering, prefixes: FULL_IGNORABLE)

          package.numbering.instances.each_with_index do |inst, idx|
            next if inst.durable_id

            raw = hex_derive("durableId:#{inst.num_id}:#{idx}", 4).to_i(16)
            raw = raw - 0x100000000 if raw >= 0x80000000
            inst.durable_id = raw.to_s
            record_fix(FixCodes::NUMBERING_REFERENCED,
                       "Generated w16cid:durableId for numId=#{inst.num_id}")
          end

          package.numbering.instances.each do |inst|
            next unless inst.abstract_num_id

            abs_id = if inst.abstract_num_id.is_a?(Uniword::Wordprocessingml::AbstractNumId)
                       inst.abstract_num_id.val
                     else
                       inst.abstract_num_id
                     end
            defn = package.numbering.definitions.find do |d|
              d.abstract_num_id == abs_id
            end
            next if defn

            record_fix(FixCodes::NUMBERING_REFERENCED, "Numbering instance numId=#{inst.num_id} references " \
                             "missing abstractNumId=#{abs_id}")
          end
        end

        def reconcile_web_settings
          return unless profile

          ws = package.web_settings
          ws ||= begin
            package.web_settings = Wordprocessingml::WebSettings.new
            package.web_settings
          end

          set_mc_ignorable(ws)
          record_fix(FixCodes::MC_IGNORABLE, "Cleared mc:Ignorable on webSettings")
        end

        def reconcile_app_properties
          return unless profile

          app = package.app_properties
          app ||= begin
            package.app_properties = Ooxml::AppProperties.new
            package.app_properties
          end

          app.template = "Normal.dotm"
          app.application = profile.application_name
          app.app_version = profile.app_version
          if profile.user_company && !profile.user_company.empty?
            app.company = profile.user_company
          end

          unless app.pages && !app.pages.to_s.empty?
            stats = calculate_document_statistics
            app.pages = stats[:pages].to_s
            app.words = stats[:words].to_s
            app.characters = stats[:characters].to_s
            app.characters_with_spaces = stats[:characters_with_spaces].to_s
            app.paragraphs = stats[:paragraphs].to_s
            app.lines = stats[:lines].to_s
          end

          app.total_time = app.total_time || "0"
          app.scale_crop = app.scale_crop || "false"
          app.doc_security = app.doc_security || "0"
          app.links_up_to_date = app.links_up_to_date || "false"
          app.shared_doc = app.shared_doc || "false"
          app.hyperlinks_changed = app.hyperlinks_changed || "false"

          app.heading_pairs = nil
          app.titles_of_parts = nil

          record_fix(FixCodes::APP_PROPERTIES_ENSURED, "Ensured app properties with statistics")
        end

        def reconcile_core_properties
          return unless profile

          old_cp = package.core_properties
          package.core_properties = if old_cp
                                     Ooxml::CoreProperties.new(
                                       title: old_cp.title,
                                       subject: old_cp.subject,
                                       creator: old_cp.creator,
                                       keywords: old_cp.keywords,
                                       description: old_cp.description,
                                       last_modified_by: old_cp.last_modified_by,
                                       revision: old_cp.revision,
                                       created: old_cp.created,
                                       modified: old_cp.modified,
                                     )
                                   else
                                     Ooxml::CoreProperties.new
                                   end
          cp = package.core_properties

          if profile.user_name && !profile.user_name.empty?
            cp.last_modified_by = profile.user_name
            cp.creator ||= profile.user_name
          end

          cp.last_modified_by ||= profile.application_name

          now = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
          cp.modified = Ooxml::Types::DctermsModifiedType.new(
            value: now, type: "dcterms:W3CDTF",
          )
          cp.created ||= Ooxml::Types::DctermsCreatedType.new(
            value: now, type: "dcterms:W3CDTF",
          )

          cp.revision = "1" unless cp.revision
          record_fix(FixCodes::CORE_PROPERTIES_REBUILT, "Rebuilt core properties with namespace declarations")
        end

        private

        def calculate_document_statistics
          DocumentStatistics.new(package).calculate
        end

        def build_compat
          Wordprocessingml::Compat.new(
            use_fe_layout: Wordprocessingml::UseFELayout.new,
            compatSetting: [
              Wordprocessingml::CompatSetting.new(
                name: "compatibilityMode",
                uri: "http://schemas.microsoft.com/office/word",
                val: profile.compat_mode,
              ),
              Wordprocessingml::CompatSetting.new(
                name: "overrideTableStyleFontSizeAndJustification",
                uri: "http://schemas.microsoft.com/office/word",
                val: "1",
              ),
              Wordprocessingml::CompatSetting.new(
                name: "enableOpenTypeFeatures",
                uri: "http://schemas.microsoft.com/office/word",
                val: "1",
              ),
              Wordprocessingml::CompatSetting.new(
                name: "doNotFlipMirrorIndents",
                uri: "http://schemas.microsoft.com/office/word",
                val: "1",
              ),
              Wordprocessingml::CompatSetting.new(
                name: "differentiateMultirowTableHeaders",
                uri: "http://schemas.microsoft.com/office/word",
                val: "1",
              ),
              Wordprocessingml::CompatSetting.new(
                name: "useWord2013TrackBottomHyphenation",
                uri: "http://schemas.microsoft.com/office/word",
                val: "0",
              ),
            ],
          )
        end

        def build_rsids(rsid)
          root = "00#{hex_derive("rsid_root", 3)}"
          Wordprocessingml::Rsids.new(
            rsid_root: Wordprocessingml::RsidRoot.new(val: root),
            rsid: [Wordprocessingml::Rsid.new(val: rsid)],
          )
        end

        def build_math_pr
          Wordprocessingml::MathPr.new(
            math_font: Wordprocessingml::MathFont.new(val: "Cambria Math"),
            brk_bin: Wordprocessingml::BrkBin.new(val: "before"),
            brk_bin_sub: Wordprocessingml::BrkBinSub.new(val: "--"),
            small_frac: Wordprocessingml::SmallFrac.new(val: "0"),
            disp_def: Wordprocessingml::DispDef.new,
            l_margin: Wordprocessingml::LMargin.new(val: "0"),
            r_margin: Wordprocessingml::RMargin.new(val: "0"),
            def_jc: Wordprocessingml::DefJc.new(val: "centerGroup"),
            wrap_indent: Wordprocessingml::WrapIndent.new(val: "1440"),
            int_lim: Wordprocessingml::IntLim.new(val: "subSup"),
            nary_lim: Wordprocessingml::NaryLim.new(val: "undOvr"),
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
              cs_theme: "minorBidi",
            ),
            kerning: Properties::Kerning.new(value: 2),
            size: Properties::FontSize.new(value: 24),
            size_cs: Properties::FontSize.new(value: 24),
            language: Properties::Language.new(
              val: profile.lang,
              east_asia: profile.east_asia_lang,
              bidi: profile.bidi_lang,
            ),
            ligatures: Uniword::Wordprocessingml2010::Ligatures.new(
              val: "standardContextual",
            ),
          )

          p_pr = Wordprocessingml::ParagraphProperties.new(
            spacing: Properties::Spacing.new(after: 160, line: 278,
                                             line_rule: "auto"),
          )

          Wordprocessingml::DocDefaults.new(
            rPrDefault: Wordprocessingml::RPrDefault.new(rPr: r_pr),
            pPrDefault: Wordprocessingml::PPrDefault.new(pPr: p_pr),
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
            if ex["unhideWhenUsed"]
              attrs[:unhide_when_used] = ex["unhideWhenUsed"]
            end
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
            lsd_exception: exceptions,
          )
        end

        def ensure_default_styles(styles)
          style_ids = styles.styles.to_set(&:id)

          unless style_ids.include?("Normal")
            styles.add_style(Wordprocessingml::Style.new(
              type: "paragraph", default: true, styleId: "Normal",
              name: Wordprocessingml::StyleName.new(val: "Normal"),
              qFormat: Properties::QuickFormat.new
            ))
          end

          unless style_ids.include?("DefaultParagraphFont")
            styles.add_style(Wordprocessingml::Style.new(
              type: "character", default: true,
              styleId: "DefaultParagraphFont",
              name: Wordprocessingml::StyleName.new(val: "Default Paragraph Font"),
              uiPriority: Wordprocessingml::UiPriority.new(val: 1),
              semiHidden: Wordprocessingml::SemiHidden.new,
              unhideWhenUsed: Wordprocessingml::UnhideWhenUsed.new
            ))
          end

          dpf = styles.styles.find { |s| s.id == "DefaultParagraphFont" }
          if dpf && !dpf.semiHidden && !allocator
            dpf.semiHidden = Wordprocessingml::SemiHidden.new
            ensure_element_in_order(dpf, "semiHidden", after: "uiPriority")
            record_fix(FixCodes::SEMI_HIDDEN_ADDED, "Added semiHidden to DefaultParagraphFont style")
          end

          unless style_ids.include?("TableNormal")
            tbl_pr = Wordprocessingml::TableProperties.new(
              table_indent: Properties::TableIndent.new(value: 0, type: "dxa"),
              table_cell_margin: Properties::TableCellMargin.new(
                top: Properties::Margin.new(w: 0, type: "dxa"),
                left: Properties::Margin.new(w: 108, type: "dxa"),
                bottom: Properties::Margin.new(w: 0, type: "dxa"),
                right: Properties::Margin.new(w: 108, type: "dxa"),
              ),
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

        def font_names_for_profile
          names = []
          fs = profile.system.font_scheme
          loc = profile.locale

          names << fs&.minor_font if fs&.minor_font

          ea_font = loc&.east_asian_font
          ea_light = loc&.east_asian_light_font

          if loc.east_asia_lang == "zh-CN"
            ea_font ||= "DengXian"
            ea_light ||= "DengXian Light"
          end

          names << ea_font if ea_font
          names << "Times New Roman"
          names << ea_light if ea_light
          names << fs&.major_font if fs&.major_font

          names.uniq
        end
      end
    end
  end
end
