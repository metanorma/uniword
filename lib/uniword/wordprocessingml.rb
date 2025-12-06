# frozen_string_literal: true

# WordprocessingML namespace module
# This file explicitly autoloads all WordprocessingML classes
# Using explicit autoload instead of dynamic Dir[] for maintainability

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Core Document Structure (8)
    autoload :Body, 'uniword/wordprocessingml/body'
    autoload :DocumentRoot, 'uniword/wordprocessingml/document_root'
    autoload :Paragraph, 'uniword/wordprocessingml/paragraph'
    autoload :Run, 'uniword/wordprocessingml/run'
    autoload :Table, 'uniword/wordprocessingml/table'
    autoload :TableRow, 'uniword/wordprocessingml/table_row'
    autoload :TableCell, 'uniword/wordprocessingml/table_cell'
    autoload :SectionProperties, 'uniword/wordprocessingml/section_properties'

    # Text & Content (12)
    autoload :Break, 'uniword/wordprocessingml/break'
    autoload :Tab, 'uniword/wordprocessingml/tab'
    autoload :TabStop, 'uniword/wordprocessingml/tab_stop'
    autoload :Symbol, 'uniword/wordprocessingml/symbol'
    autoload :InstrText, 'uniword/wordprocessingml/instr_text'
    autoload :FieldChar, 'uniword/wordprocessingml/field_char'
    autoload :Hyperlink, 'uniword/wordprocessingml/hyperlink'
    autoload :Link, 'uniword/wordprocessingml/link'
    autoload :Object, 'uniword/wordprocessingml/object'
    autoload :TextBoxContent, 'uniword/wordprocessingml/text_box_content'
    autoload :Emboss, 'uniword/wordprocessingml/emboss'
    autoload :Imprint, 'uniword/wordprocessingml/imprint'

    # Table Structure (7)
    autoload :TableGrid, 'uniword/wordprocessingml/table_grid'
    autoload :GridCol, 'uniword/wordprocessingml/grid_col'
    autoload :TableBorders, 'uniword/wordprocessingml/table_borders'
    autoload :TableCellBorders, 'uniword/wordprocessingml/table_cell_borders'
    autoload :TableRowProperties, 'uniword/wordprocessingml/table_row_properties'
    autoload :TableCellProperties, 'uniword/wordprocessingml/table_cell_properties'
    autoload :ParagraphBorders, 'uniword/wordprocessingml/paragraph_borders'

    # Properties & Formatting (5)
    autoload :Border, 'uniword/wordprocessingml/border'
    autoload :Shading, 'uniword/wordprocessingml/shading'
    autoload :Shadow, 'uniword/wordprocessingml/shadow'
    autoload :Outline, 'uniword/wordprocessingml/outline'
    autoload :Columns, 'uniword/wordprocessingml/columns'

    # Styles (6)
    autoload :Style, 'uniword/wordprocessingml/style'
    autoload :StyleName, 'uniword/wordprocessingml/style_name'
    autoload :BasedOn, 'uniword/wordprocessingml/based_on'
    autoload :Next, 'uniword/wordprocessingml/next'
    autoload :LatentStyles, 'uniword/wordprocessingml/latent_styles'
    autoload :UiPriority, 'uniword/wordprocessingml/ui_priority'

    # Numbering & Lists (9)
    autoload :Numbering, 'uniword/wordprocessingml/numbering'
    autoload :Num, 'uniword/wordprocessingml/num'
    autoload :AbstractNum, 'uniword/wordprocessingml/abstract_num'
    autoload :AbstractNumId, 'uniword/wordprocessingml/abstract_num_id'
    autoload :Level, 'uniword/wordprocessingml/level'
    autoload :LvlText, 'uniword/wordprocessingml/lvl_text'
    autoload :LvlJc, 'uniword/wordprocessingml/lvl_jc'
    autoload :NumFmt, 'uniword/wordprocessingml/num_fmt'
    autoload :MultiLevelType, 'uniword/wordprocessingml/multi_level_type'

    # Bookmarks & References (8)
    autoload :BookmarkStart, 'uniword/wordprocessingml/bookmark_start'
    autoload :BookmarkEnd, 'uniword/wordprocessingml/bookmark_end'
    autoload :CommentRangeStart, 'uniword/wordprocessingml/comment_range_start'
    autoload :CommentRangeEnd, 'uniword/wordprocessingml/comment_range_end'
    autoload :CommentReference, 'uniword/wordprocessingml/comment_reference'
    autoload :FootnoteReference, 'uniword/wordprocessingml/footnote_reference'
    autoload :EndnoteReference, 'uniword/wordprocessingml/endnote_reference'
    autoload :Start, 'uniword/wordprocessingml/start'

    # Headers & Footers (6)
    autoload :Header, 'uniword/wordprocessingml/header'
    autoload :Footer, 'uniword/wordprocessingml/footer'
    autoload :HeaderReference, 'uniword/wordprocessingml/header_reference'
    autoload :FooterReference, 'uniword/wordprocessingml/footer_reference'
    autoload :Footnote, 'uniword/wordprocessingml/footnote'
    autoload :Footnotes, 'uniword/wordprocessingml/footnotes'
    autoload :Endnote, 'uniword/wordprocessingml/endnote'
    autoload :Endnotes, 'uniword/wordprocessingml/endnotes'

    # Page Layout (5)
    autoload :PageSize, 'uniword/wordprocessingml/page_size'
    autoload :PageMargins, 'uniword/wordprocessingml/page_margins'
    autoload :PageNumbering, 'uniword/wordprocessingml/page_numbering'
    autoload :PageBorders, 'uniword/wordprocessingml/page_borders'
    autoload :Zoom, 'uniword/wordprocessingml/zoom'

    # Document Settings & Defaults (6)
    autoload :Settings, 'uniword/wordprocessingml/settings'
    autoload :DocDefaults, 'uniword/wordprocessingml/doc_defaults'
    autoload :DocPr, 'uniword/wordprocessingml/doc_pr'
    autoload :PPrDefault, 'uniword/wordprocessingml/p_pr_default'
    autoload :RPrDefault, 'uniword/wordprocessingml/r_pr_default'
    autoload :Compat, 'uniword/wordprocessingml/compat'
    autoload :CompatSetting, 'uniword/wordprocessingml/compat_setting'

    # Fonts (2)
    autoload :Font, 'uniword/wordprocessingml/font'
    autoload :Fonts, 'uniword/wordprocessingml/fonts'

    # Drawing & Images (11)
    autoload :Drawing, 'uniword/wordprocessingml/drawing'
    autoload :Inline, 'uniword/wordprocessingml/inline'
    autoload :Anchor, 'uniword/wordprocessingml/anchor'
    autoload :Extent, 'uniword/wordprocessingml/extent'
    autoload :SimplePos, 'uniword/wordprocessingml/simple_pos'
    autoload :Pict, 'uniword/wordprocessingml/pict'
    autoload :Picture, 'uniword/wordprocessingml/picture'
    autoload :Shape, 'uniword/wordprocessingml/shape'
    autoload :Graphic, 'uniword/wordprocessingml/graphic'
    autoload :GraphicData, 'uniword/wordprocessingml/graphic_data'
    autoload :AlternateContent, 'uniword/wordprocessingml/alternate_content'
    autoload :Choice, 'uniword/wordprocessingml/choice'
    autoload :Fallback, 'uniword/wordprocessingml/fallback'
    autoload :McRequires, 'uniword/wordprocessingml/mc_requires'

    # Structured Document Tags (SDT) (3)
    autoload :StructuredDocumentTag, 'uniword/wordprocessingml/structured_document_tag'
    autoload :SdtContent, 'uniword/wordprocessingml/sdt_content'
    autoload :SdtEndProperties, 'uniword/wordprocessingml/sdt_end_properties'
  end
end