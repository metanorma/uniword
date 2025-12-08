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
    autoload :TextBoxContent, 'uniword/wordprocessingml/text_box_content'

    # Compatibility
    autoload :AlternateContent, 'uniword/wordprocessingml/alternate_content'
    autoload :Choice, 'uniword/wordprocessingml/choice'
    autoload :Fallback, 'uniword/wordprocessingml/fallback'
    autoload :McRequires, 'uniword/wordprocessingml/mc_requires'
    autoload :Drawing, 'uniword/wordprocessingml/drawing'

    # Structure and metadata
    autoload :Level, 'uniword/wordprocessingml/level'
    autoload :Style, 'uniword/wordprocessingml/style'
    autoload :StructuredDocumentTag, 'uniword/wordprocessingml/structured_document_tag'
    autoload :SdtContent, 'uniword/wordprocessingml/sdt_content'
    autoload :SdtEndProperties, 'uniword/wordprocessingml/sdt_end_properties'
    autoload :SectionProperties, 'uniword/wordprocessingml/section_properties'

    # Numbering
    autoload :Start, 'uniword/wordprocessingml/start'
    autoload :NumFmt, 'uniword/wordprocessingml/num_fmt'
    autoload :LvlText, 'uniword/wordprocessingml/lvl_text'
    autoload :LvlJc, 'uniword/wordprocessingml/lvl_jc'

    # Style elements
    autoload :StyleName, 'uniword/wordprocessingml/style_name'
    autoload :BasedOn, 'uniword/wordprocessingml/based_on'
    autoload :Next, 'uniword/wordprocessingml/next'
    autoload :Link, 'uniword/wordprocessingml/link'
    autoload :UiPriority, 'uniword/wordprocessingml/ui_priority'

    # Properties
    autoload :TableCellProperties, 'uniword/wordprocessingml/table_cell_properties'
    autoload :TableRowProperties, 'uniword/wordprocessingml/table_row_properties'
    autoload :TableCellBorders, 'uniword/wordprocessingml/table_cell_borders'
    autoload :RPrDefault, 'uniword/wordprocessingml/r_pr_default'
    autoload :PPrDefault, 'uniword/wordprocessingml/p_pr_default'

    # Grid
    autoload :GridCol, 'uniword/wordprocessingml/grid_col'
  end
end