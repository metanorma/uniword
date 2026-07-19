# frozen_string_literal: true

require "lutaml/model"
require "nokogiri"

module Uniword
  module Wordprocessingml
    # Document settings
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:settings>
    class Settings < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :zoom, Zoom
      attribute :do_not_display_page_boundaries, DoNotDisplayPageBoundaries
      attribute :compat, Compat
      attribute :proof_state, ProofState
      attribute :style_pane_format_filter, StylePaneFormatFilter
      attribute :default_tab_stop, DefaultTabStop
      attribute :character_spacing_control, CharacterSpacingControl
      attribute :rsids, Rsids
      attribute :math_pr, MathPr
      attribute :theme_font_lang, ThemeFontLang
      attribute :clr_scheme_mapping, ClrSchemeMapping
      attribute :shape_defaults, ShapeDefaults
      attribute :decimal_symbol, DecimalSymbol
      attribute :list_separator, ListSeparator
      attribute :attached_template, AttachedTemplate
      attribute :footnote_pr, FootnotePr
      attribute :endnote_pr, EndnotePr
      attribute :hdr_shape_defaults, HdrShapeDefaults
      attribute :update_fields, UpdateFields
      attribute :even_and_odd_headers, EvenAndOddHeaders
      attribute :mirror_margins, MirrorMargins
      attribute :do_not_include_subdocs_in_stats,
                DoNotIncludeSubdocsInStats
      attribute :hyphenation_zone, HyphenationZone
      attribute :style_pane_sort_method, StylePaneSortMethod
      attribute :doc_vars, DocVars
      attribute :w14_doc_id, W14DocId
      attribute :w15_chart_tracking_ref_based, W15ChartTrackingRefBased
      attribute :w15_doc_id, W15DocId
      attribute :mc_ignorable, Uniword::Ooxml::Types::McIgnorable
      attribute :schema_library, Uniword::Ooxml::SchemaLibrary

      xml do
        element "settings"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # Force namespace declarations on root element for child elements from different namespaces
        # This ensures w14:, w15:, m:, o:, and sl: prefixes are declared at the settings level
        namespace_scope [
          { namespace: Uniword::Ooxml::Namespaces::Word2010, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2012, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::MathML, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Office, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::MarkupCompatibility,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::SchemaLibrary,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Relationships,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Vml, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::VmlWord, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2018Cex,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2016Cid,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2018, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2023Du,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2020SdtDataHash,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2024SdtFormatLock,
            declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2015Symex,
            declare: :always },
        ]

        map_attribute "Ignorable", to: :mc_ignorable, render_nil: false
        # Element order MUST match OOXML CT_Settings schema sequence.
        # Out-of-order elements cause Word "unreadable content" errors.
        map_element "zoom", to: :zoom, render_nil: false
        map_element "doNotDisplayPageBoundaries",
                    to: :do_not_display_page_boundaries, render_nil: false
        map_element "mirrorMargins", to: :mirror_margins, render_nil: false
        map_element "proofState", to: :proof_state, render_nil: false
        map_element "attachedTemplate", to: :attached_template,
                                        render_nil: false
        map_element "stylePaneFormatFilter", to: :style_pane_format_filter,
                                             render_nil: false
        map_element "stylePaneSortMethod", to: :style_pane_sort_method,
                                           render_nil: false
        map_element "defaultTabStop", to: :default_tab_stop, render_nil: false
        map_element "hyphenationZone", to: :hyphenation_zone,
                                       render_nil: false
        map_element "evenAndOddHeaders", to: :even_and_odd_headers,
                                         render_nil: false
        map_element "characterSpacingControl", to: :character_spacing_control,
                                               render_nil: false
        map_element "updateFields", to: :update_fields, render_nil: false
        map_element "hdrShapeDefaults", to: :hdr_shape_defaults,
                                        render_nil: false
        map_element "footnotePr", to: :footnote_pr, render_nil: false
        map_element "endnotePr", to: :endnote_pr, render_nil: false
        map_element "compat", to: :compat, render_nil: false
        map_element "docVars", to: :doc_vars, render_nil: false
        map_element "rsids", to: :rsids, render_nil: false
        map_element "mathPr", to: :math_pr, render_nil: false
        map_element "themeFontLang", to: :theme_font_lang, render_nil: false
        map_element "clrSchemeMapping", to: :clr_scheme_mapping,
                                        render_nil: false
        map_element "doNotIncludeSubdocsInStats",
                    to: :do_not_include_subdocs_in_stats, render_nil: false
        # Both w14:docId and w15:docId use the same element name 'docId'
        # Separate map_element entries needed for namespace-aware matching
        # The namespace_scope ensures w14 and w15 namespaces are declared on root
        map_element "chartTrackingRefBased", to: :w15_chart_tracking_ref_based,
                                             render_nil: false
        map_element "docId", to: :w14_doc_id, render_nil: false
        map_element "docId", to: :w15_doc_id, render_nil: false
        map_element "schemaLibrary", to: :schema_library, render_nil: false
        map_element "shapeDefaults", to: :shape_defaults, render_nil: false
        map_element "decimalSymbol", to: :decimal_symbol, render_nil: false
        map_element "listSeparator", to: :list_separator, render_nil: false
      end

      # Override from_xml to manually deserialize w15:docId which has the same
      # element name as w14:docId and can't be distinguished by map_element alone.
      # Note: Both docId elements have their values captured via map_element (w14)
      # and from_xml (w15). The w15:docId's GUID is preserved in the model.
      def self.from_xml(xml_content)
        settings = super

        doc = Nokogiri::XML(xml_content)
        doc_ids = doc.xpath('//*[local-name()="docId"]')
        doc_ids.each do |elem|
          ns_uri = elem.namespace&.href
          val = elem.attributes["val"]&.value
          next unless val

          if (ns_uri == "http://schemas.microsoft.com/office/word/2012/wordml") && !settings.w15_doc_id&.val
            # w15:docId - manually deserialize since map_element captures w14:docId
            settings.w15_doc_id = W15DocId.new(val: val)
          end
          # w14:docId is captured by map_element 'docId', no action needed
        end

        settings
      end
    end
  end
end
