# frozen_string_literal: true

module Uniword
  module Properties
    # Simple wrappers
    autoload :Alignment, 'uniword/properties/alignment'
    autoload :FontSize, 'uniword/properties/font_size'
    autoload :Color, 'uniword/properties/color'
    autoload :ColorValue, 'uniword/properties/color_value'
    autoload :StyleReference, 'uniword/properties/style_reference'
    autoload :OutlineLevel, 'uniword/properties/outline_level'
    autoload :Underline, 'uniword/properties/underline'
    autoload :Highlight, 'uniword/properties/highlight'
    autoload :VerticalAlign, 'uniword/properties/vertical_align'
    autoload :Position, 'uniword/properties/position'
    autoload :CharacterSpacing, 'uniword/properties/character_spacing'
    autoload :Kerning, 'uniword/properties/kerning'
    autoload :WidthScale, 'uniword/properties/width_scale'
    autoload :EmphasisMark, 'uniword/properties/emphasis_mark'
    autoload :NumberingId, 'uniword/properties/numbering_id'
    autoload :NumberingLevel, 'uniword/properties/numbering_level'
    autoload :NumberingProperties, 'uniword/properties/numbering_properties'
    autoload :Tabs, 'uniword/properties/tabs'

    # Boolean formatting classes (from boolean_formatting.rb)
    autoload :Strike, 'uniword/properties/boolean_formatting'
    autoload :DoubleStrike, 'uniword/properties/boolean_formatting'
    autoload :SmallCaps, 'uniword/properties/boolean_formatting'
    autoload :Caps, 'uniword/properties/boolean_formatting'
    autoload :Vanish, 'uniword/properties/boolean_formatting'
    autoload :NoProof, 'uniword/properties/boolean_formatting'
    autoload :Shadow, 'uniword/properties/boolean_formatting'
    autoload :Emboss, 'uniword/properties/boolean_formatting'
    autoload :Imprint, 'uniword/properties/boolean_formatting'
    autoload :QuickFormat, 'uniword/properties/boolean_formatting'
    autoload :KeepNext, 'uniword/properties/boolean_formatting'
    autoload :KeepLines, 'uniword/properties/boolean_formatting'
    autoload :ContextualSpacing, 'uniword/properties/contextual_spacing'

    # Bold and Italic (from bold.rb and italic.rb)
    autoload :Bold, 'uniword/properties/bold'
    autoload :Italic, 'uniword/properties/italic'

    # Complex objects
    autoload :Spacing, 'uniword/properties/spacing'
    autoload :Indentation, 'uniword/properties/indentation'
    autoload :RunFonts, 'uniword/properties/run_fonts'
    autoload :Border, 'uniword/properties/border'
    autoload :Borders, 'uniword/properties/borders'
    autoload :TabStop, 'uniword/properties/tab_stop'
    autoload :Shading, 'uniword/properties/shading'
    autoload :Language, 'uniword/properties/language'
    autoload :TextFill, 'uniword/properties/text_fill'
    autoload :TextOutline, 'uniword/properties/text_outline'
    autoload :Margin, 'uniword/properties/margin'

    # Table-specific
    autoload :TableWidth, 'uniword/properties/table_width'
    autoload :TableCellMargin, 'uniword/properties/table_cell_margin'
    autoload :TableLook, 'uniword/properties/table_look'
    autoload :TableIndent, 'uniword/properties/table_indent'
    autoload :CellWidth, 'uniword/properties/cell_width'
    autoload :CellVerticalAlign, 'uniword/properties/cell_vertical_align'
  end
end
