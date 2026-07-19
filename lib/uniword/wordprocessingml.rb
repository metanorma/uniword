# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # Core document structure
    autoload :DocumentRoot, "uniword/wordprocessingml/document_root"
    autoload :Body, "uniword/wordprocessingml/body"
    autoload :Paragraph, "uniword/wordprocessingml/paragraph"
    autoload :Run, "uniword/wordprocessingml/run"
    autoload :Table, "uniword/wordprocessingml/table"
    autoload :TableRow, "uniword/wordprocessingml/table_row"
    autoload :TableCell, "uniword/wordprocessingml/table_cell"
    autoload :TableGrid, "uniword/wordprocessingml/table_grid"

    # Paragraph elements
    autoload :Hyperlink, "uniword/wordprocessingml/hyperlink"
    autoload :BookmarkStart, "uniword/wordprocessingml/bookmark_start"
    autoload :BookmarkEnd, "uniword/wordprocessingml/bookmark_end"
    autoload :FieldChar, "uniword/wordprocessingml/field_char"
    autoload :InstrText, "uniword/wordprocessingml/instr_text"
    autoload :ProofErr, "uniword/wordprocessingml/proof_err"
    autoload :CommentRangeStart, "uniword/wordprocessingml/comment_range_start"
    autoload :CommentRangeEnd, "uniword/wordprocessingml/comment_range_end"
    autoload :CommentReference, "uniword/wordprocessingml/comment_reference"

    # Run elements
    autoload :Tab, "uniword/wordprocessingml/tab"
    autoload :Break, "uniword/wordprocessingml/break"
    autoload :PositionTab, "uniword/wordprocessingml/position_tab"
    autoload :Pict, "uniword/wordprocessingml/pict"
    autoload :Symbol, "uniword/wordprocessingml/symbol"
    autoload :DeletedText, "uniword/wordprocessingml/deleted_text"
    autoload :NoBreakHyphen, "uniword/wordprocessingml/no_break_hyphen"
    autoload :LastRenderedPageBreak,
             "uniword/wordprocessingml/last_rendered_page_break"
    autoload :CarriageReturn, "uniword/wordprocessingml/carriage_return"
    autoload :SeparatorChar, "uniword/wordprocessingml/separator_char"
    autoload :ContinuationSeparatorChar,
             "uniword/wordprocessingml/separator_char"
    autoload :SimpleField, "uniword/wordprocessingml/simple_field"
    autoload :TextBoxContent, "uniword/wordprocessingml/text_box_content"
    autoload :Object, "uniword/wordprocessingml/object"

    # Compatibility
    autoload :AlternateContent, "uniword/wordprocessingml/alternate_content"
    autoload :Choice, "uniword/wordprocessingml/choice"
    autoload :Fallback, "uniword/wordprocessingml/fallback"
    autoload :McRequires, "uniword/wordprocessingml/mc_requires"
    autoload :Compat, "uniword/wordprocessingml/compat"
    autoload :CompatSetting, "uniword/wordprocessingml/compat_setting"

    # Drawing and graphics
    autoload :Drawing, "uniword/wordprocessingml/drawing"
    autoload :Anchor, "uniword/wordprocessingml/anchor"
    autoload :Inline, "uniword/wordprocessingml/inline"
    autoload :Extent, "uniword/wordprocessingml/extent"
    autoload :DocPr, "uniword/wordprocessingml/doc_pr"
    autoload :SimplePos, "uniword/wordprocessingml/simple_pos"
    autoload :Graphic, "uniword/wordprocessingml/graphic"
    autoload :GraphicData, "uniword/wordprocessingml/graphic_data"
    autoload :Picture, "uniword/wordprocessingml/picture"
    autoload :Shape, "uniword/wordprocessingml/shape"

    # Structure and metadata
    autoload :Level, "uniword/wordprocessingml/level"
    autoload :Style, "uniword/wordprocessingml/style"
    autoload :StyleCleanup, "uniword/wordprocessingml/style_cleanup"
    autoload :StructuredDocumentTag,
             "uniword/wordprocessingml/structured_document_tag"
    autoload :StructuredDocumentTagProperties,
             "uniword/wordprocessingml/structured_document_tag_properties"
    autoload :SectionProperties, "uniword/wordprocessingml/section_properties"
    autoload :PageSize, "uniword/wordprocessingml/page_size"
    autoload :PageMargins, "uniword/wordprocessingml/page_margins"
    autoload :PageNumbering, "uniword/wordprocessingml/page_numbering"
    autoload :PageSetup, "uniword/wordprocessingml/page_setup"
    autoload :Columns, "uniword/wordprocessingml/columns"
    autoload :HeaderReference, "uniword/wordprocessingml/header_reference"
    autoload :FooterReference, "uniword/wordprocessingml/footer_reference"
    autoload :Header, "uniword/wordprocessingml/header"
    autoload :Footer, "uniword/wordprocessingml/footer"

    # Document settings and defaults
    autoload :Settings, "uniword/wordprocessingml/settings"
    autoload :ProofState, "uniword/wordprocessingml/proof_state"
    autoload :StylePaneFormatFilter, "uniword/wordprocessingml/style_pane_format_filter"
    autoload :DefaultTabStop, "uniword/wordprocessingml/default_tab_stop"
    autoload :CharacterSpacingControl, "uniword/wordprocessingml/character_spacing_control"
    autoload :DoNotDisplayPageBoundaries, "uniword/wordprocessingml/do_not_display_page_boundaries"
    autoload :Rsids, "uniword/wordprocessingml/rsids"
    autoload :RsidRoot, "uniword/wordprocessingml/rsid_root"
    autoload :Rsid, "uniword/wordprocessingml/rsid"
    autoload :MathPr, "uniword/wordprocessingml/math_pr"
    autoload :MathFont, "uniword/wordprocessingml/math_font"
    autoload :BrkBin, "uniword/wordprocessingml/brk_bin"
    autoload :BrkBinSub, "uniword/wordprocessingml/brk_bin_sub"
    autoload :SmallFrac, "uniword/wordprocessingml/small_frac"
    autoload :DispDef, "uniword/wordprocessingml/disp_def"
    autoload :LMargin, "uniword/wordprocessingml/l_margin"
    autoload :RMargin, "uniword/wordprocessingml/r_margin"
    autoload :DefJc, "uniword/wordprocessingml/def_jc"
    autoload :WrapIndent, "uniword/wordprocessingml/wrap_indent"
    autoload :IntLim, "uniword/wordprocessingml/int_lim"
    autoload :NaryLim, "uniword/wordprocessingml/nary_lim"
    autoload :ThemeFontLang, "uniword/wordprocessingml/theme_font_lang"
    autoload :ClrSchemeMapping, "uniword/wordprocessingml/clr_scheme_mapping"
    autoload :ShapeDefaults, "uniword/wordprocessingml/shape_defaults"
    autoload :DecimalSymbol, "uniword/wordprocessingml/decimal_symbol"
    autoload :ListSeparator, "uniword/wordprocessingml/list_separator"
    autoload :W14DocId, "uniword/wordprocessingml/w14_doc_id"
    autoload :W15ChartTrackingRefBased, "uniword/wordprocessingml/w15_chart_tracking_ref_based"
    autoload :W15DocId, "uniword/wordprocessingml/w15_doc_id"
    autoload :AttachedTemplate, "uniword/wordprocessingml/attached_template"
    autoload :HdrShapeDefaults, "uniword/wordprocessingml/hdr_shape_defaults"
    autoload :EvenAndOddHeaders, "uniword/wordprocessingml/even_and_odd_headers"
    autoload :MirrorMargins, "uniword/wordprocessingml/mirror_margins"
    autoload :DoNotIncludeSubdocsInStats,
             "uniword/wordprocessingml/do_not_include_subdocs_in_stats"
    autoload :HyphenationZone, "uniword/wordprocessingml/hyphenation_zone"
    autoload :StylePaneSortMethod,
             "uniword/wordprocessingml/style_pane_sort_method"
    autoload :DocVar, "uniword/wordprocessingml/doc_vars"
    autoload :DocVars, "uniword/wordprocessingml/doc_vars"
    autoload :FootnotePos, "uniword/wordprocessingml/footnote_pos"
    autoload :FootnotePr, "uniword/wordprocessingml/footnote_pr"
    autoload :EndnotePr, "uniword/wordprocessingml/endnote_pr"
    autoload :SemiHidden, "uniword/wordprocessingml/semi_hidden"
    autoload :UnhideWhenUsed, "uniword/wordprocessingml/semi_hidden"
    autoload :LatentStylesException, "uniword/wordprocessingml/latent_styles"
    autoload :DocDefaults, "uniword/wordprocessingml/doc_defaults"
    autoload :Zoom, "uniword/wordprocessingml/zoom"

    # Fonts
    autoload :Font, "uniword/wordprocessingml/font"
    autoload :FontReplacer, "uniword/wordprocessingml/font_replacer"
    autoload :Fonts, "uniword/wordprocessingml/fonts"
    autoload :FontTable, "uniword/wordprocessingml/font_table"

    # Web settings
    autoload :WebSettings, "uniword/wordprocessingml/web_settings"
    autoload :OptimizeForBrowser,
             "uniword/wordprocessingml/optimize_for_browser"
    autoload :AllowPng, "uniword/wordprocessingml/allow_png"
    autoload :DivBorder, "uniword/wordprocessingml/div_border"
    autoload :DivBorders, "uniword/wordprocessingml/div_borders"
    autoload :MarLeft, "uniword/wordprocessingml/mar_left"
    autoload :MarRight, "uniword/wordprocessingml/mar_right"
    autoload :MarTop, "uniword/wordprocessingml/mar_top"
    autoload :MarBottom, "uniword/wordprocessingml/mar_bottom"
    autoload :BodyDiv, "uniword/wordprocessingml/body_div"
    autoload :DivsChild, "uniword/wordprocessingml/divs_child"
    autoload :WebDiv, "uniword/wordprocessingml/web_div"
    autoload :WebDivs, "uniword/wordprocessingml/web_divs"
    autoload :WebEncoding, "uniword/wordprocessingml/web_encoding"

    # Numbering
    autoload :AbstractNum, "uniword/wordprocessingml/abstract_num"
    autoload :AbstractNumId, "uniword/wordprocessingml/numbering_elements"
    autoload :Num, "uniword/wordprocessingml/num"
    autoload :Numbering, "uniword/wordprocessingml/numbering"
    autoload :MultiLevelType, "uniword/wordprocessingml/multi_level_type"
    autoload :Nsid, "uniword/wordprocessingml/numbering_elements"
    autoload :Tmpl, "uniword/wordprocessingml/numbering_elements"
    autoload :Start, "uniword/wordprocessingml/start"
    autoload :NumFmt, "uniword/wordprocessingml/num_fmt"
    autoload :LvlText, "uniword/wordprocessingml/lvl_text"
    autoload :LvlJc, "uniword/wordprocessingml/lvl_jc"
    autoload :Ind, "uniword/wordprocessingml/numbering_elements"
    autoload :RFonts, "uniword/wordprocessingml/numbering_elements"
    autoload :Tabs, "uniword/wordprocessingml/level"
    autoload :PStyle, "uniword/wordprocessingml/level"
    autoload :NumberingConfiguration,
             "uniword/wordprocessingml/numbering_configuration"
    autoload :NumberingDefinition,
             "uniword/wordprocessingml/numbering_definition"
    autoload :NumberingInstance, "uniword/wordprocessingml/numbering_instance"
    autoload :NumberingLevel, "uniword/wordprocessingml/numbering_level"
    autoload :StylesConfiguration,
             "uniword/wordprocessingml/styles_configuration"

    # Footnotes and endnotes
    autoload :Footnote, "uniword/wordprocessingml/footnote"
    autoload :FootnoteReference, "uniword/wordprocessingml/footnote_reference"
    autoload :FootnoteRef, "uniword/wordprocessingml/footnote_ref"
    autoload :Footnotes, "uniword/wordprocessingml/footnotes"
    autoload :Endnote, "uniword/wordprocessingml/endnote"
    autoload :EndnoteReference, "uniword/wordprocessingml/endnote_reference"
    autoload :EndnoteRef, "uniword/wordprocessingml/endnote_ref"
    autoload :Endnotes, "uniword/wordprocessingml/endnotes"

    # Style elements
    autoload :StyleName, "uniword/wordprocessingml/style_name"
    autoload :BasedOn, "uniword/wordprocessingml/based_on"
    autoload :Next, "uniword/wordprocessingml/next"
    autoload :Link, "uniword/wordprocessingml/link"
    autoload :UiPriority, "uniword/wordprocessingml/ui_priority"
    autoload :UpdateFields, "uniword/wordprocessingml/update_fields"
    autoload :LatentStyles, "uniword/wordprocessingml/latent_styles"
    autoload :ParagraphStyle, "uniword/wordprocessingml/paragraph_style"
    autoload :CharacterStyle, "uniword/wordprocessingml/character_style"

    # Text effects
    autoload :Emboss, "uniword/wordprocessingml/emboss"
    autoload :Imprint, "uniword/wordprocessingml/imprint"
    autoload :Outline, "uniword/wordprocessingml/outline"
    autoload :Shadow, "uniword/wordprocessingml/shadow"

    # Properties
    autoload :TableCellProperties,
             "uniword/wordprocessingml/table_cell_properties"
    autoload :TableRowProperties,
             "uniword/wordprocessingml/table_row_properties"
    autoload :TableCellBorders, "uniword/wordprocessingml/table_cell_borders"
    autoload :Border, "uniword/wordprocessingml/border"
    autoload :ParagraphBorders, "uniword/wordprocessingml/paragraph_borders"
    autoload :TableBorders, "uniword/wordprocessingml/table_borders"
    autoload :TableStyle, "uniword/wordprocessingml/table_style"
    autoload :RPrDefault, "uniword/wordprocessingml/r_pr_default"
    autoload :PPrDefault, "uniword/wordprocessingml/p_pr_default"
    autoload :Shading, "uniword/wordprocessingml/shading"
    autoload :TabStop, "uniword/wordprocessingml/tab_stop"

    # Table cell/row helper types
    autoload :ValInt, "uniword/wordprocessingml/val_int"
    autoload :TrHeight, "uniword/wordprocessingml/tr_height"
    autoload :GridBefore, "uniword/wordprocessingml/grid_before"
    autoload :GridAfter, "uniword/wordprocessingml/grid_after"
    autoload :WidthBefore, "uniword/wordprocessingml/width_before"
    autoload :WidthAfter, "uniword/wordprocessingml/width_after"
    autoload :TableCellMargin, "uniword/wordprocessingml/table_cell_margin"
    autoload :CnfStyle, "uniword/wordprocessingml/cnf_style"
    autoload :NoWrap, "uniword/wordprocessingml/no_wrap"
    autoload :HideMark, "uniword/wordprocessingml/hide_mark"
    autoload :TextDirection, "uniword/wordprocessingml/text_direction"

    # Properties classes (consolidated from Ooxml::WordProcessingML)
    autoload :ParagraphProperties,
             "uniword/wordprocessingml/paragraph_properties"
    autoload :RunProperties, "uniword/wordprocessingml/run_properties"
    autoload :TableProperties, "uniword/wordprocessingml/table_properties"

    autoload :W14ParaId, "uniword/wordprocessingml/w14_attributes"
    autoload :W14TextId, "uniword/wordprocessingml/w14_attributes"
    autoload :W15RestartNumberingAfterBreak,
             "uniword/wordprocessingml/w14_attributes"
    autoload :W16CidDurableId, "uniword/wordprocessingml/w14_attributes"
    autoload :DocGrid, "uniword/wordprocessingml/doc_grid"
    autoload :TitlePg, "uniword/wordprocessingml/title_pg"
    autoload :Text, "uniword/wordprocessingml/text"

    # Grid
    autoload :GridCol, "uniword/wordprocessingml/grid_col"

    # Mail merge
    autoload :Recipients, "uniword/wordprocessingml/recipients"
    autoload :RecipientData, "uniword/wordprocessingml/recipient_data"

    # Shared defaults
    autoload :PageDefaults, "uniword/wordprocessingml/page_defaults"
    autoload :TableDefaults, "uniword/wordprocessingml/table_defaults"
  end
end
