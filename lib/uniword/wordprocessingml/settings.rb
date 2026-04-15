# frozen_string_literal: true

require "lutaml/model"
require_relative "../properties/relationship_id"

module Uniword
  module Wordprocessingml
    # Proof state for spelling/grammar checking
    #
    # Element: <w:proofState>
    class ProofState < Lutaml::Model::Serializable
      attribute :spelling, :string
      attribute :grammar, :string

      xml do
        element "proofState"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "spelling", to: :spelling
        map_attribute "grammar", to: :grammar
      end
    end

    # Style pane format filter
    #
    # Element: <w:stylePaneFormatFilter>
    class StylePaneFormatFilter < Lutaml::Model::Serializable
      attribute :val, :string
      attribute :all_styles, :string
      attribute :custom_styles, :string
      attribute :latent_styles, :string
      attribute :styles_in_use, :string
      attribute :heading_styles, :string
      attribute :numbering_styles, :string
      attribute :table_styles, :string
      attribute :direct_formatting_on_runs, :string
      attribute :direct_formatting_on_paragraphs, :string
      attribute :direct_formatting_on_numbering, :string
      attribute :direct_formatting_on_tables, :string
      attribute :clear_formatting, :string
      attribute :top3_heading_styles, :string
      attribute :visible_styles, :string
      attribute :alternate_style_names, :string

      xml do
        element "stylePaneFormatFilter"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
        map_attribute "allStyles", to: :all_styles
        map_attribute "customStyles", to: :custom_styles
        map_attribute "latentStyles", to: :latent_styles
        map_attribute "stylesInUse", to: :styles_in_use
        map_attribute "headingStyles", to: :heading_styles
        map_attribute "numberingStyles", to: :numbering_styles
        map_attribute "tableStyles", to: :table_styles
        map_attribute "directFormattingOnRuns", to: :direct_formatting_on_runs
        map_attribute "directFormattingOnParagraphs", to: :direct_formatting_on_paragraphs
        map_attribute "directFormattingOnNumbering", to: :direct_formatting_on_numbering
        map_attribute "directFormattingOnTables", to: :direct_formatting_on_tables
        map_attribute "clearFormatting", to: :clear_formatting
        map_attribute "top3HeadingStyles", to: :top3_heading_styles
        map_attribute "visibleStyles", to: :visible_styles
        map_attribute "alternateStyleNames", to: :alternate_style_names
      end
    end

    # Default tab stop
    #
    # Element: <w:defaultTabStop>
    class DefaultTabStop < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "defaultTabStop"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # Character spacing control
    #
    # Element: <w:characterSpacingControl>
    class CharacterSpacingControl < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "characterSpacingControl"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # RSID root marker
    #
    # Element: <w:rsidRoot>
    class RsidRoot < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "rsidRoot"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # RSID marker
    #
    # Element: <w:rsid>
    class Rsid < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "rsid"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # RSID collection container
    #
    # Element: <w:rsids>
    class Rsids < Lutaml::Model::Serializable
      attribute :rsid_root, RsidRoot
      attribute :rsid, Rsid, collection: true

      xml do
        element "rsids"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "rsidRoot", to: :rsid_root, render_nil: false
        map_element "rsid", to: :rsid, render_nil: false
      end
    end

    # Math font reference
    #
    # Element: <m:mathFont>
    class MathFont < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "mathFont"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :val
      end
    end

    # Break binary operator
    #
    # Element: <m:brkBin>
    class BrkBin < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "brkBin"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :val
      end
    end

    # Break binary subtraction operator
    #
    # Element: <m:brkBinSub>
    class BrkBinSub < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "brkBinSub"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :val
      end
    end

    # Small fraction
    #
    # Element: <m:smallFrac>
    class SmallFrac < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "smallFrac"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :val
      end
    end

    # Display default (empty marker)
    #
    # Element: <m:dispDef>
    class DispDef < Lutaml::Model::Serializable
      xml do
        element "dispDef"
        namespace Uniword::Ooxml::Namespaces::MathML
      end
    end

    # Left margin
    #
    # Element: <m:lMargin>
    class LMargin < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "lMargin"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :val
      end
    end

    # Right margin
    #
    # Element: <m:rMargin>
    class RMargin < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "rMargin"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :val
      end
    end

    # Default justification
    #
    # Element: <m:defJc>
    class DefJc < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "defJc"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :val
      end
    end

    # Wrap indent
    #
    # Element: <m:wrapIndent>
    class WrapIndent < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "wrapIndent"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :val
      end
    end

    # Integral limit
    #
    # Element: <m:intLim>
    class IntLim < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "intLim"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :val
      end
    end

    # N-ary limit
    #
    # Element: <m:naryLim>
    class NaryLim < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "naryLim"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :val
      end
    end

    # Math properties container
    #
    # Element: <m:mathPr>
    class MathPr < Lutaml::Model::Serializable
      attribute :math_font, MathFont
      attribute :brk_bin, BrkBin
      attribute :brk_bin_sub, BrkBinSub
      attribute :small_frac, SmallFrac
      attribute :disp_def, DispDef
      attribute :l_margin, LMargin
      attribute :r_margin, RMargin
      attribute :def_jc, DefJc
      attribute :wrap_indent, WrapIndent
      attribute :int_lim, IntLim
      attribute :nary_lim, NaryLim

      xml do
        element "mathPr"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content
        map_element "mathFont", to: :math_font, render_nil: false
        map_element "brkBin", to: :brk_bin, render_nil: false
        map_element "brkBinSub", to: :brk_bin_sub, render_nil: false
        map_element "smallFrac", to: :small_frac, render_nil: false
        map_element "dispDef", to: :disp_def, render_nil: false
        map_element "lMargin", to: :l_margin, render_nil: false
        map_element "rMargin", to: :r_margin, render_nil: false
        map_element "defJc", to: :def_jc, render_nil: false
        map_element "wrapIndent", to: :wrap_indent, render_nil: false
        map_element "intLim", to: :int_lim, render_nil: false
        map_element "naryLim", to: :nary_lim, render_nil: false
      end
    end

    # Theme font language
    #
    # Element: <w:themeFontLang>
    class ThemeFontLang < Lutaml::Model::Serializable
      attribute :val, :string
      attribute :east_asia, :string

      xml do
        element "themeFontLang"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
        map_attribute "eastAsia", to: :east_asia
      end
    end

    # Color scheme mapping
    #
    # Element: <w:clrSchemeMapping>
    class ClrSchemeMapping < Lutaml::Model::Serializable
      attribute :bg1, :string
      attribute :t1, :string
      attribute :bg2, :string
      attribute :t2, :string
      attribute :accent1, :string
      attribute :accent2, :string
      attribute :accent3, :string
      attribute :accent4, :string
      attribute :accent5, :string
      attribute :accent6, :string
      attribute :hyperlink, :string
      attribute :followed_hyperlink, :string

      xml do
        element "clrSchemeMapping"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "bg1", to: :bg1
        map_attribute "t1", to: :t1
        map_attribute "bg2", to: :bg2
        map_attribute "t2", to: :t2
        map_attribute "accent1", to: :accent1
        map_attribute "accent2", to: :accent2
        map_attribute "accent3", to: :accent3
        map_attribute "accent4", to: :accent4
        map_attribute "accent5", to: :accent5
        map_attribute "accent6", to: :accent6
        map_attribute "hyperlink", to: :hyperlink
        map_attribute "followedHyperlink", to: :followed_hyperlink
      end
    end

    # Shape defaults container
    #
    # Element: <w:shapeDefaults>
    class ShapeDefaults < Lutaml::Model::Serializable
      attribute :shape_defaults, Uniword::VmlOffice::VmlShapeDefaults
      attribute :shape_layout, Uniword::VmlOffice::VmlShapeLayout

      xml do
        element "shapeDefaults"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "shapedefaults", to: :shape_defaults, render_nil: false
        map_element "shapelayout", to: :shape_layout, render_nil: false
      end
    end

    # Decimal symbol
    #
    # Element: <w:decimalSymbol>
    class DecimalSymbol < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "decimalSymbol"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # List separator
    #
    # Element: <w:listSeparator>
    class ListSeparator < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "listSeparator"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # Attached template reference
    #
    # Element: <w:attachedTemplate>
    class AttachedTemplate < Lutaml::Model::Serializable
      attribute :r_id, Properties::RelationshipIdValue

      xml do
        element "attachedTemplate"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "id", to: :r_id
      end
    end

    # Header/footer shape defaults container
    #
    # Element: <w:hdrShapeDefaults>
    class HdrShapeDefaults < Lutaml::Model::Serializable
      attribute :shape_defaults, Uniword::VmlOffice::VmlShapeDefaults

      xml do
        element "hdrShapeDefaults"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "shapedefaults", to: :shape_defaults, render_nil: false
      end
    end

    # Footnote position
    #
    # Element: <w:pos>
    class FootnotePos < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "pos"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # Footnote properties
    #
    # Element: <w:footnotePr>
    class FootnotePr < Lutaml::Model::Serializable
      attribute :pos, FootnotePos
      attribute :footnotes, Footnote, collection: true

      xml do
        element "footnotePr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "pos", to: :pos, render_nil: false
        map_element "footnote", to: :footnotes, render_nil: false
      end
    end

    # Endnote properties
    #
    # Element: <w:endnotePr>
    class EndnotePr < Lutaml::Model::Serializable
      attribute :endnotes, Endnote, collection: true

      xml do
        element "endnotePr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "endnote", to: :endnotes, render_nil: false
      end
    end

    # Word 2010 document ID
    #
    # Element: <w14:docId>
    class W14DocId < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "docId"
        namespace Uniword::Ooxml::Namespaces::Word2010
        map_attribute "val", to: :val
      end
    end

    # Word 2012 chart tracking ref based (empty marker)
    #
    # Element: <w15:chartTrackingRefBased>
    class W15ChartTrackingRefBased < Lutaml::Model::Serializable
      xml do
        element "chartTrackingRefBased"
        namespace Uniword::Ooxml::Namespaces::Word2012
      end
    end

    # Word 2012 document ID
    #
    # Element: <w15:docId>
    class W15DocId < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "docId"
        namespace Uniword::Ooxml::Namespaces::Word2012
        map_attribute "val", to: :val
      end
    end

    # Document settings
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:settings>
    class Settings < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :zoom, Zoom
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
          { namespace: Uniword::Ooxml::Namespaces::MarkupCompatibility, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::SchemaLibrary, declare: :always }
        ]

        map_attribute "Ignorable", to: :mc_ignorable, render_nil: false
        map_element "zoom", to: :zoom, render_nil: false
        map_element "compat", to: :compat, render_nil: false
        map_element "proofState", to: :proof_state, render_nil: false
        map_element "stylePaneFormatFilter", to: :style_pane_format_filter, render_nil: false
        map_element "defaultTabStop", to: :default_tab_stop, render_nil: false
        map_element "characterSpacingControl", to: :character_spacing_control, render_nil: false
        map_element "rsids", to: :rsids, render_nil: false
        map_element "mathPr", to: :math_pr, render_nil: false
        map_element "themeFontLang", to: :theme_font_lang, render_nil: false
        map_element "clrSchemeMapping", to: :clr_scheme_mapping, render_nil: false
        map_element "shapeDefaults", to: :shape_defaults, render_nil: false
        map_element "decimalSymbol", to: :decimal_symbol, render_nil: false
        map_element "listSeparator", to: :list_separator, render_nil: false
        map_element "attachedTemplate", to: :attached_template, render_nil: false
        map_element "footnotePr", to: :footnote_pr, render_nil: false
        map_element "endnotePr", to: :endnote_pr, render_nil: false
        map_element "hdrShapeDefaults", to: :hdr_shape_defaults, render_nil: false
        # Both w14:docId and w15:docId use the same element name 'docId'
        # Separate map_element entries needed for namespace-aware matching
        # The namespace_scope ensures w14 and w15 namespaces are declared on root
        map_element "chartTrackingRefBased", to: :w15_chart_tracking_ref_based, render_nil: false
        map_element "docId", to: :w14_doc_id, render_nil: false
        map_element "docId", to: :w15_doc_id, render_nil: false
        map_element "schemaLibrary", to: :schema_library, render_nil: false
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
