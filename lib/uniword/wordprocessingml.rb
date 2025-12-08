# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # Core document structure
    autoload :DocumentRoot, 'uniword/wordprocessingml/document_root'
    autoload :Body, 'uniword/wordprocessingml/body'
    autoload :Paragraph, 'uniword/wordprocessingml/paragraph'
    autoload :Run, 'uniword/wordprocessingml/run'
    autoload :Table, 'uniword/wordprocessingml/table'
    autoload :TableRow, 'uniword/wordprocessingml/table_row'
    autoload :TableCell, 'uniword/wordprocessingml/table_cell'
    autoload :TableGrid, 'uniword/wordprocessingml/table_grid'

    # Paragraph elements
    autoload :Hyperlink, 'uniword/wordprocessingml/hyperlink'
    autoload :BookmarkStart, 'uniword/wordprocessingml/bookmark_start'
    autoload :BookmarkEnd, 'uniword/wordprocessingml/bookmark_end'
    autoload :FieldChar, 'uniword/wordprocessingml/field_char'
    autoload :InstrText, 'uniword/wordprocessingml/instr_text'
    autoload :CommentRangeStart, 'uniword/wordprocessingml/comment_range_start'
    autoload :CommentRangeEnd, 'uniword/wordprocessingml/comment_range_end'
    autoload :CommentReference, 'uniword/wordprocessingml/comment_reference'

    # Run elements
    autoload :Tab, 'uniword/wordprocessingml/tab'
    autoload :Break, 'uniword/wordprocessingml/break'
    autoload :Pict, 'uniword/wordprocessingml/pict'
    autoload :Symbol, 'uniword/wordprocessingml/symbol'
    autoload :TextBoxContent, 'uniword/wordprocessingml/text_box_content'
    autoload :Object, 'uniword/wordprocessingml/object'

    # Compatibility
    autoload :AlternateContent, 'uniword/wordprocessingml/alternate_content'
    autoload :Choice, 'uniword/wordprocessingml/choice'
    autoload :Fallback, 'uniword/wordprocessingml/fallback'
    autoload :McRequires, 'uniword/wordprocessingml/mc_requires'
    autoload :Compat, 'uniword/wordprocessingml/compat'
    autoload :CompatSetting, 'uniword/wordprocessingml/compat_setting'

    # Drawing and graphics
    autoload :Drawing, 'uniword/wordprocessingml/drawing'
    autoload :Anchor, 'uniword/wordprocessingml/anchor'
    autoload :Inline, 'uniword/wordprocessingml/inline'
    autoload :Extent, 'uniword/wordprocessingml/extent'
    autoload :DocPr, 'uniword/wordprocessingml/doc_pr'
    autoload :SimplePos, 'uniword/wordprocessingml/simple_pos'
    autoload :Graphic, 'uniword/wordprocessingml/graphic'
    autoload :GraphicData, 'uniword/wordprocessingml/graphic_data'
    autoload :Picture, 'uniword/wordprocessingml/picture'
    autoload :Shape, 'uniword/wordprocessingml/shape'

    # Structure and metadata
    autoload :Level, 'uniword/wordprocessingml/level'
    autoload :Style, 'uniword/wordprocessingml/style'
    autoload :StructuredDocumentTag, 'uniword/wordprocessingml/structured_document_tag'
    autoload :SdtContent, 'uniword/wordprocessingml/sdt_content'
    autoload :SdtEndProperties, 'uniword/wordprocessingml/sdt_end_properties'
    autoload :SectionProperties, 'uniword/wordprocessingml/section_properties'
    autoload :PageSize, 'uniword/wordprocessingml/page_size'
    autoload :PageMargins, 'uniword/wordprocessingml/page_margins'
    autoload :PageNumbering, 'uniword/wordprocessingml/page_numbering'
    autoload :Columns, 'uniword/wordprocessingml/columns'
    autoload :HeaderReference, 'uniword/wordprocessingml/header_reference'
    autoload :FooterReference, 'uniword/wordprocessingml/footer_reference'
    autoload :Header, 'uniword/wordprocessingml/header'
    autoload :Footer, 'uniword/wordprocessingml/footer'

    # Document settings and defaults
    autoload :Settings, 'uniword/wordprocessingml/settings'
    autoload :DocDefaults, 'uniword/wordprocessingml/doc_defaults'
    autoload :Zoom, 'uniword/wordprocessingml/zoom'

    # Fonts
    autoload :Font, 'uniword/wordprocessingml/font'
    autoload :Fonts, 'uniword/wordprocessingml/fonts'

    # Numbering
    autoload :AbstractNum, 'uniword/wordprocessingml/abstract_num'
    autoload :AbstractNumId, 'uniword/wordprocessingml/abstract_num_id'
    autoload :Num, 'uniword/wordprocessingml/num'
    autoload :Numbering, 'uniword/wordprocessingml/numbering'
    autoload :MultiLevelType, 'uniword/wordprocessingml/multi_level_type'
    autoload :Start, 'uniword/wordprocessingml/start'
    autoload :NumFmt, 'uniword/wordprocessingml/num_fmt'
    autoload :LvlText, 'uniword/wordprocessingml/lvl_text'
    autoload :LvlJc, 'uniword/wordprocessingml/lvl_jc'

    # Footnotes and endnotes
    autoload :Footnote, 'uniword/wordprocessingml/footnote'
    autoload :FootnoteReference, 'uniword/wordprocessingml/footnote_reference'
    autoload :Footnotes, 'uniword/wordprocessingml/footnotes'
    autoload :Endnote, 'uniword/wordprocessingml/endnote'
    autoload :EndnoteReference, 'uniword/wordprocessingml/endnote_reference'
    autoload :Endnotes, 'uniword/wordprocessingml/endnotes'

    # Style elements
    autoload :StyleName, 'uniword/wordprocessingml/style_name'
    autoload :BasedOn, 'uniword/wordprocessingml/based_on'
    autoload :Next, 'uniword/wordprocessingml/next'
    autoload :Link, 'uniword/wordprocessingml/link'
    autoload :UiPriority, 'uniword/wordprocessingml/ui_priority'
    autoload :LatentStyles, 'uniword/wordprocessingml/latent_styles'

    # Text effects
    autoload :Emboss, 'uniword/wordprocessingml/emboss'
    autoload :Imprint, 'uniword/wordprocessingml/imprint'
    autoload :Outline, 'uniword/wordprocessingml/outline'
    autoload :Shadow, 'uniword/wordprocessingml/shadow'

    # Properties
    autoload :TableCellProperties, 'uniword/wordprocessingml/table_cell_properties'
    autoload :TableRowProperties, 'uniword/wordprocessingml/table_row_properties'
    autoload :TableCellBorders, 'uniword/wordprocessingml/table_cell_borders'
    autoload :Border, 'uniword/wordprocessingml/border'
    autoload :ParagraphBorders, 'uniword/wordprocessingml/paragraph_borders'
    autoload :TableBorders, 'uniword/wordprocessingml/table_borders'
    autoload :RPrDefault, 'uniword/wordprocessingml/r_pr_default'
    autoload :PPrDefault, 'uniword/wordprocessingml/p_pr_default'
    autoload :Shading, 'uniword/wordprocessingml/shading'
    autoload :TabStop, 'uniword/wordprocessingml/tab_stop'

    # Properties classes (consolidated from Ooxml::WordProcessingML)
    autoload :ParagraphProperties, 'uniword/wordprocessingml/paragraph_properties'
    autoload :RunProperties, 'uniword/wordprocessingml/run_properties'
    autoload :TableProperties, 'uniword/wordprocessingml/table_properties'

    # Grid
    autoload :GridCol, 'uniword/wordprocessingml/grid_col'
  end
end