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
        @applied_fixes = []
      end

      def reconcile
        # Group 1: Document body (always)
        reconcile_section_properties
        reconcile_footnotes
        reconcile_endnotes
        repair_theme

        # Group 2: Support parts (profile-dependent)
        if @profile
          reconcile_theme
          reconcile_settings
          reconcile_font_table
          reconcile_styles
          reconcile_numbering
          reconcile_web_settings
          reconcile_app_properties
          reconcile_core_properties
          reconcile_document_body
        end

        # Clear stored namespace plans so declare: :always scopes take effect
        clear_stored_namespace_plans

        # Group 3: Package consistency (always)
        reconcile_content_types
        reconcile_package_rels
        reconcile_document_rels
      end

      # Audit trail of fixes applied during reconciliation.
      # Each entry is { validity_rule:, message:, timestamp: }.
      attr_reader :applied_fixes

      private

      attr_reader :package, :profile

      def record_fix(validity_rule, message)
        @applied_fixes << {
          validity_rule: validity_rule,
          message: message,
          timestamp: Time.now,
        }
      end

      # Clear stored namespace plans from parsed XML so that
      # declare: :always namespace_scopes take full effect during
      # serialization. Without this, parsed objects limit namespace
      # declarations to only those present in the source XML.
      def clear_stored_namespace_plans
        parts = [
          package.document,
          package.settings,
          package.font_table,
          package.styles,
          package.web_settings,
          package.numbering,
          package.core_properties,
          package.app_properties,
        ].compact

        parts.each do |part|
          part.instance_variable_set(:@pending_namespace_data, nil)
          part.instance_variable_set(:@import_declaration_plan, nil)
          part.instance_variable_set(:@xml_input_namespaces, nil)
        end
      end

      # -- Section Properties --

      def reconcile_section_properties
        return unless package.document&.body

        body = package.document.body

        unless body.section_properties
          body.section_properties = Wordprocessingml::SectionProperties.new(
            page_size: Wordprocessingml::PageSize.new(width: 12_240,
                                                      height: 15_840),
            page_margins: Wordprocessingml::PageMargins.new(
              top: 1440, right: 1440, bottom: 1440, left: 1440,
              header: 720, footer: 720, gutter: 0
            ),
            columns: Wordprocessingml::Columns.new(space: 720),
            doc_grid: Wordprocessingml::DocGrid.new(line_pitch: 360),
          )
          record_fix("R11", "Added default section properties with US Letter page size")
          return
        end

        sect_pr = body.section_properties
        fixed = false
        unless sect_pr.page_size
          sect_pr.page_size = Wordprocessingml::PageSize.new(width: 12_240, height: 15_840)
          fixed = true
        end
        unless sect_pr.page_margins
          sect_pr.page_margins = Wordprocessingml::PageMargins.new(
            top: 1440, right: 1440, bottom: 1440, left: 1440,
            header: 720, footer: 720, gutter: 0
          )
          fixed = true
        end
        record_fix("R11", "Filled missing pgSz/pgMar in existing section properties") if fixed
      end

      # -- Footnotes --

      def reconcile_footnotes
        has_fn_pr = package.settings&.footnote_pr
        has_footnotes = package.footnotes

        if has_fn_pr && !has_footnotes
          package.footnotes = minimal_footnotes
          record_fix("R9", "Created footnotes.xml to match footnotePr in settings")
        elsif has_footnotes && !has_fn_pr
          package.settings ||= Wordprocessingml::Settings.new
          package.settings.footnote_pr = Wordprocessingml::FootnotePr.new
          record_fix("R9", "Added footnotePr to settings to match footnotes.xml")
        end

        ensure_separators(package.footnotes, :footnote) if package.footnotes
      end

      # -- Endnotes --

      def reconcile_endnotes
        has_en_pr = package.settings&.endnote_pr
        has_endnotes = package.endnotes

        if has_en_pr && !has_endnotes
          package.endnotes = minimal_endnotes
          record_fix("R9", "Created endnotes.xml to match endnotePr in settings")
        elsif has_endnotes && !has_en_pr
          package.settings ||= Wordprocessingml::Settings.new
          package.settings.endnote_pr = Wordprocessingml::EndnotePr.new
          record_fix("R9", "Added endnotePr to settings to match endnotes.xml")
        end

        ensure_separators(package.endnotes, :endnote) if package.endnotes
      end

      # -- Builders --

      def minimal_footnotes
        Wordprocessingml::Footnotes.new(
          footnote_entries: [separator_entry(:footnote),
                             continuation_entry(:footnote)],
        )
      end

      def minimal_endnotes
        Wordprocessingml::Endnotes.new(
          endnote_entries: [separator_entry(:endnote),
                            continuation_entry(:endnote)],
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
        ids = entries.to_set(&:id)

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
          word_theme = friendly.to_word_theme
          word_theme.name = "Office Theme"
          package.theme = word_theme
          record_fix("R3", "Created default theme with complete fmtScheme")
        rescue ArgumentError
          nil
        end
      end

      # Repair broken theme fmtScheme even without a profile.
      # Word replaces the entire theme on repair; we fill minimum content.
      def repair_theme
        theme = package.theme
        return unless theme

        fmt = theme.theme_elements&.fmt_scheme
        return unless fmt

        repaired = false

        if count_fill_styles(fmt.fill_style_lst) < 2
          ensure_minimal_fill_list(fmt)
          repaired = true
        end

        if count_line_styles(fmt.ln_style_lst) < 3
          ensure_minimal_line_list(fmt)
          repaired = true
        end

        if count_effect_styles(fmt.effect_style_lst) < 3
          ensure_minimal_effect_list(fmt)
          repaired = true
        end

        if count_fill_styles(fmt.bg_fill_style_lst) < 2
          ensure_minimal_bg_fill_list(fmt)
          repaired = true
        end

        record_fix("R3", "Repaired theme fmtScheme with minimum required content") if repaired
      end

      def count_fill_styles(lst)
        return 0 unless lst
        (lst.solid_fills || []).size + (lst.gradient_fills || []).size + (lst.blip_fills || []).size
      end

      def count_line_styles(lst)
        return 0 unless lst
        (lst.lines || []).size
      end

      def count_effect_styles(lst)
        return 0 unless lst
        (lst.effect_styles || []).size
      end

      def ensure_minimal_fill_list(fmt)
        lst = fmt.fill_style_lst || Drawingml::FillStyleList.new
        fills = Array(lst.solid_fills).dup
        while fills.size < 2
          fills << Drawingml::SolidFill.new(
            scheme_color: Drawingml::SchemeColor.new(val: "accent#{fills.size + 1}")
          )
        end
        lst.solid_fills = fills
        fmt.fill_style_lst = lst
      end

      def ensure_minimal_line_list(fmt)
        lst = fmt.ln_style_lst || Drawingml::LineStyleList.new
        lines = Array(lst.lines).dup
        widths = [9525, 25400, 38100]
        while lines.size < 3
          idx = lines.size
          lines << Drawingml::LineProperties.new(
            width: widths[idx] || 9525,
            solid_fill: Drawingml::SolidFill.new(
              scheme_color: Drawingml::SchemeColor.new(val: "accent#{idx + 1}")
            )
          )
        end
        lst.lines = lines
        fmt.ln_style_lst = lst
      end

      def ensure_minimal_effect_list(fmt)
        lst = fmt.effect_style_lst || Drawingml::EffectStyleList.new
        styles = Array(lst.effect_styles).dup
        while styles.size < 3
          styles << Drawingml::EffectStyle.new
        end
        lst.effect_styles = styles
        fmt.effect_style_lst = lst
      end

      def ensure_minimal_bg_fill_list(fmt)
        lst = fmt.bg_fill_style_lst || Drawingml::BackgroundFillStyleList.new
        fills = Array(lst.solid_fills).dup
        while fills.size < 2
          fills << Drawingml::SolidFill.new(
            scheme_color: Drawingml::SchemeColor.new(val: "accent#{fills.size + 1}")
          )
        end
        lst.solid_fills = fills
        fmt.bg_fill_style_lst = lst
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
        settings.do_not_display_page_boundaries ||= Wordprocessingml::DoNotDisplayPageBoundaries.new
        settings.proof_state ||= Wordprocessingml::ProofState.new(
          spelling: "clean", grammar: "clean",
        )
        settings.default_tab_stop ||= Wordprocessingml::DefaultTabStop.new(val: "720")
        settings.character_spacing_control ||= Wordprocessingml::CharacterSpacingControl.new(
          val: "doNotCompress",
        )

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
            val: SecureRandom.hex(4).upcase,
          )
          record_fix("R2", "Generated w14:docId")
        end
        unless settings.w15_doc_id
          settings.w15_doc_id = Wordprocessingml::W15DocId.new(
            val: "{#{SecureRandom.uuid.upcase}}",
          )
          record_fix("R2", "Generated w15:docId in GUID format")
        end

        unless settings.mc_ignorable
          settings.mc_ignorable = Ooxml::Types::McIgnorable.new(
            "w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du",
          )
          record_fix("R1", "Added mc:Ignorable to settings")
        end
      end

      def reconcile_font_table
        return unless profile

        font_table = package.font_table
        font_table ||= begin
          package.font_table = Wordprocessingml::FontTable.new
          record_fix("R13", "Created font table")
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
            ),
          )

          font.alt_name = Wordprocessingml::AltName.new(val: meta["alt_name"]) if meta["alt_name"]
          font_table.fonts << font
        end

        font_table.mc_ignorable ||= Ooxml::Types::McIgnorable.new(
          "w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du",
        )
        record_fix("R13", "Populated font table with profile fonts and signatures")
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
          "w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du",
        )
        record_fix("R10", "Ensured styles have docDefaults, latentStyles, and default styles")
      end

      def reconcile_numbering
        return unless profile
        return unless package.numbering

        unless package.numbering.mc_ignorable
          package.numbering.mc_ignorable = Ooxml::Types::McIgnorable.new(
            "w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du wp14",
          )
          record_fix("R1", "Added mc:Ignorable to numbering")
        end

        # Validate instance → definition references
        package.numbering.instances.each do |inst|
          next unless inst.abstract_num_id

          abs_id = inst.abstract_num_id.respond_to?(:val) ? inst.abstract_num_id.val : inst.abstract_num_id
          defn = package.numbering.definitions.find { |d| d.abstract_num_id == abs_id }
          next if defn

          record_fix("R4", "Numbering instance numId=#{inst.num_id} references " \
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

        ws.mc_ignorable ||= Ooxml::Types::McIgnorable.new(
          "w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du",
        )
        record_fix("R1", "Added mc:Ignorable to webSettings")
      end

      def reconcile_app_properties
        return unless profile

        app = package.app_properties
        app ||= begin
          package.app_properties = Ooxml::AppProperties.new
          package.app_properties
        end

        # Always assign to override lutaml-model's using_default tracking,
        # which prevents serialization of attributes that equal their defaults.
        app.template = "Normal.dotm"
        app.application = profile.application_name
        app.app_version = profile.app_version
        app.company = profile.user_company if profile.user_company && !profile.user_company.empty?

        # Calculate document statistics only when missing
        unless app.pages && !app.pages.to_s.empty?
          stats = calculate_document_statistics
          app.pages = stats[:pages].to_s
          app.words = stats[:words].to_s
          app.characters = stats[:characters].to_s
          app.characters_with_spaces = stats[:characters_with_spaces].to_s
          app.paragraphs = stats[:paragraphs].to_s
          app.lines = stats[:lines].to_s
        end

        # Re-assign to clear lutaml-model's @using_default tracking
        # which otherwise omits these from XML output.
        # Preserve source values when present.
        app.total_time = app.total_time || "0"
        app.scale_crop = app.scale_crop || "false"
        app.doc_security = app.doc_security || "0"
        app.links_up_to_date = app.links_up_to_date || "false"
        app.shared_doc = app.shared_doc || "false"
        app.hyperlinks_changed = app.hyperlinks_changed || "false"

        # HeadingPairs and TitlesOfParts are NOT generated here.
        # Word repairs files that have incorrect values, so we only
        # preserve what was parsed from the source document.
        record_fix("R8", "Ensured app properties with statistics")
      end

      def reconcile_core_properties
        return unless profile

        # Rebuild from parsed state to ensure namespace_scope
        # declarations (e.g. xmlns:dcmitype) are applied on
        # serialization (lutaml-model preserves parsed namespaces)
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
        record_fix("R14", "Rebuilt core properties with namespace declarations")
      end

      def reconcile_document_body
        return unless profile
        return unless package.document&.body

        doc = package.document
        doc.mc_ignorable ||= Ooxml::Types::McIgnorable.new(
          "w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du wp14",
        )

        record_fix("R1", "Added mc:Ignorable to document body")
        record_fix("R12", "Assigned rsid and paraId to paragraphs")

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
            content_type: "application/vnd.openxmlformats-package.relationships+xml",
          ),
          Uniword::ContentTypes::Default.new(
            extension: "xml",
            content_type: "application/xml",
          ),
        ]

        # Overrides: rebuild for standard parts that exist
        standard = content_type_overrides_for_present_parts
        standard_parts = standard.to_set(&:part_name)
        non_standard = ct.overrides.reject do |o|
          standard_parts.include?(o.part_name)
        end

        ct.overrides = standard + non_standard
        record_fix("R7", "Rebuilt content types for standard parts")
      end

      def reconcile_package_rels
        rels = package.package_rels
        return unless rels

        base = "http://schemas.openxmlformats.org"
        standard_defs = [
          ["rId1",
           "#{base}/officeDocument/2006/relationships/officeDocument",
           "word/document.xml"],
          ["rId2",
           "#{base}/package/2006/relationships/metadata/core-properties",
           "docProps/core.xml"],
          ["rId3",
           "#{base}/officeDocument/2006/relationships/extended-properties",
           "docProps/app.xml"],
        ]

        standard_targets = standard_defs.map { |_, _, t| t }.to_set
        standard_rids = standard_defs.map { |rid, _, _| rid }.to_set
        non_standard = rels.relationships.reject do |r|
          standard_targets.include?(r.target) || standard_rids.include?(r.id)
        end

        existing_by_target = rels.relationships.each_with_object({}) { |r, h| h[r.target] = r }
        standard = standard_defs.map do |rid, type, target|
          existing = existing_by_target[target]
          build_rel(existing ? existing.id : rid, type, target)
        end

        rels.relationships = standard + non_standard
        record_fix("R6", "Rebuilt package relationships for standard parts")
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
          ["rId5", "theme", "theme/theme1.xml", package.theme],
          ["rId6", "numbering", "numbering.xml", package.numbering],
        ]

        standard_targets = defs.filter_map { |_, _, target, obj| target if obj }.to_set
        standard_rids = defs.filter_map { |rid, _, _, obj| rid if obj }.to_set
        non_standard = rels.relationships.reject do |r|
          standard_targets.include?(r.target) || standard_rids.include?(r.id)
        end

        # Reuse existing rIds for matching targets to avoid duplicates
        existing_by_target = rels.relationships.each_with_object({}) { |r, h| h[r.target] = r }
        standard = defs.filter_map do |_rid, suffix, target, obj|
          next unless obj

          existing = existing_by_target[target]
          rid = existing ? existing.id : _rid
          build_rel(rid, "#{base}/#{suffix}", target)
        end

        rels.relationships = standard + non_standard
        record_fix("R6", "Rebuilt document relationships for standard parts")
      end

      # -- Helpers --

      def calculate_document_statistics
        DocumentStatistics.new(package).calculate
      end

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
           "application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"],
        ]

        checks.filter_map do |obj, part_name, content_type|
          next unless obj

          Uniword::ContentTypes::Override.new(
            part_name: part_name,
            content_type: content_type,
          )
        end
      end

      def build_rel(id, type, target)
        Ooxml::Relationships::Relationship.new(
          id: id, type: type, target: target,
        )
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
        root = "00#{SecureRandom.hex(3).upcase}"
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
            attrs[:unhide_when_used] =
              ex["unhideWhenUsed"]
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
        loc = profile.locale

        # Order matches Word's canonical output:
        # 1. Minor font (body), 2. East Asian font, 3. Legacy serif,
        # 4. East Asian light font, 5. Major font (headings)
        names << fs&.minor_font if fs&.minor_font

        ea_font = loc.respond_to?(:east_asian_font) && loc.east_asian_font
        ea_light = loc.respond_to?(:east_asian_light_font) && loc.east_asian_light_font

        # Default East Asian fonts for zh-CN when locale profile omits them
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
