# frozen_string_literal: true

# DrawingML namespace module
# This file explicitly autoloads all DrawingML classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# Namespace: http://schemas.openxmlformats.org/drawingml/2006/main
# Prefix: a:

module Uniword
  module Drawingml
    # Graphics Primitives (7)
    autoload :Graphic, 'uniword/drawingml/graphic'
    autoload :GraphicData, 'uniword/drawingml/graphic_data'
    autoload :Blip, 'uniword/drawingml/blip'
    autoload :BlipFill, 'uniword/drawingml/blip_fill'
    autoload :Stretch, 'uniword/drawingml/stretch'
    autoload :Tile, 'uniword/drawingml/tile'
    autoload :SourceRect, 'uniword/drawingml/source_rect'

    # Shapes (4)
    autoload :Shape, 'uniword/drawingml/shape'
    autoload :NonVisualShapeProperties, 'uniword/drawingml/non_visual_shape_properties'
    autoload :NonVisualDrawingProperties, 'uniword/drawingml/non_visual_drawing_properties'
    autoload :ShapeProperties, 'uniword/drawingml/shape_properties'

    # Style & References (4)
    autoload :StyleMatrix, 'uniword/drawingml/style_matrix'
    autoload :StyleReference, 'uniword/drawingml/style_reference'
    autoload :FontReference, 'uniword/drawingml/font_reference'
    autoload :LineDefaults, 'uniword/drawingml/line_defaults'

    # Transforms (3)
    autoload :Transform2D, 'uniword/drawingml/transform2_d'
    autoload :Offset, 'uniword/drawingml/offset'
    autoload :Extents, 'uniword/drawingml/extents'

    # Line Properties (6)
    autoload :LineProperties, 'uniword/drawingml/line_properties'
    autoload :PresetDash, 'uniword/drawingml/preset_dash'
    autoload :CustomDash, 'uniword/drawingml/custom_dash'
    autoload :DashStop, 'uniword/drawingml/dash_stop'
    autoload :LineJoinRound, 'uniword/drawingml/line_join_round'
    autoload :LineJoinMiter, 'uniword/drawingml/line_join_miter'

    # Text Body & Structure (4)
    autoload :TextBody, 'uniword/drawingml/text_body'
    autoload :BodyProperties, 'uniword/drawingml/body_properties'
    autoload :TextParagraph, 'uniword/drawingml/text_paragraph'
    autoload :TextRun, 'uniword/drawingml/text_run'

    # Text Properties (10)
    autoload :ListStyle, 'uniword/drawingml/list_style'
    autoload :DefaultParagraphProperties, 'uniword/drawingml/default_paragraph_properties'
    autoload :Level1ParagraphProperties, 'uniword/drawingml/level1_paragraph_properties'
    autoload :Level2ParagraphProperties, 'uniword/drawingml/level2_paragraph_properties'
    autoload :Level3ParagraphProperties, 'uniword/drawingml/level3_paragraph_properties'
    autoload :TextParagraphProperties, 'uniword/drawingml/text_paragraph_properties'
    autoload :TextCharacterProperties, 'uniword/drawingml/text_character_properties'
    autoload :TextFont, 'uniword/drawingml/text_font'
    autoload :EastAsianFont, 'uniword/drawingml/east_asian_font'
    autoload :ComplexScriptFont, 'uniword/drawingml/complex_script_font'

    # Basic Fills (2)
    autoload :SolidFill, 'uniword/drawingml/solid_fill'
    autoload :NoFill, 'uniword/drawingml/no_fill'

    # Colors (2)
    autoload :SrgbColor, 'uniword/drawingml/srgb_color'
    autoload :SchemeColor, 'uniword/drawingml/scheme_color'

    # Gradient Fills (10)
    autoload :GradientFill, 'uniword/drawingml/gradient_fill'
    autoload :GradientStopList, 'uniword/drawingml/gradient_stop_list'
    autoload :GradientStop, 'uniword/drawingml/gradient_stop'
    autoload :LinearGradient, 'uniword/drawingml/linear_gradient'
    autoload :PathGradient, 'uniword/drawingml/path_gradient'
    autoload :FillToRect, 'uniword/drawingml/fill_to_rect'
    autoload :TileRect, 'uniword/drawingml/tile_rect'
    autoload :PatternFill, 'uniword/drawingml/pattern_fill'
    autoload :ForegroundColor, 'uniword/drawingml/foreground_color'
    autoload :BackgroundColor, 'uniword/drawingml/background_color'

    # Effects (15)
    autoload :EffectList, 'uniword/drawingml/effect_list'
    autoload :EffectContainer, 'uniword/drawingml/effect_container'
    autoload :Glow, 'uniword/drawingml/glow'
    autoload :InnerShadow, 'uniword/drawingml/inner_shadow'
    autoload :OuterShadow, 'uniword/drawingml/outer_shadow'
    autoload :PresetShadow, 'uniword/drawingml/preset_shadow'
    autoload :Reflection, 'uniword/drawingml/reflection'
    autoload :SoftEdge, 'uniword/drawingml/soft_edge'
    autoload :Blur, 'uniword/drawingml/blur'
    autoload :FillOverlay, 'uniword/drawingml/fill_overlay'
    autoload :Duotone, 'uniword/drawingml/duotone'
    autoload :AlphaBiLevel, 'uniword/drawingml/alpha_bi_level'
    autoload :AlphaModulationFixed, 'uniword/drawingml/alpha_modulation_fixed'
    autoload :BiLevel, 'uniword/drawingml/bi_level'
    autoload :Grayscale, 'uniword/drawingml/grayscale'

    # Color Transforms (21)
    autoload :Alpha, 'uniword/drawingml/alpha'
    autoload :AlphaOffset, 'uniword/drawingml/alpha_offset'
    autoload :AlphaModulation, 'uniword/drawingml/alpha_modulation'
    autoload :Hue, 'uniword/drawingml/hue'
    autoload :HueOffset, 'uniword/drawingml/hue_offset'
    autoload :HueModulation, 'uniword/drawingml/hue_modulation'
    autoload :Saturation, 'uniword/drawingml/saturation'
    autoload :SaturationOffset, 'uniword/drawingml/saturation_offset'
    autoload :SaturationModulation, 'uniword/drawingml/saturation_modulation'
    autoload :Luminance, 'uniword/drawingml/luminance'
    autoload :LuminanceOffset, 'uniword/drawingml/luminance_offset'
    autoload :LuminanceModulation, 'uniword/drawingml/luminance_modulation'
    autoload :Red, 'uniword/drawingml/red'
    autoload :RedOffset, 'uniword/drawingml/red_offset'
    autoload :RedModulation, 'uniword/drawingml/red_modulation'
    autoload :Green, 'uniword/drawingml/green'
    autoload :Blue, 'uniword/drawingml/blue'
    autoload :Gamma, 'uniword/drawingml/gamma'
    autoload :InverseGamma, 'uniword/drawingml/inverse_gamma'
    autoload :Tint, 'uniword/drawingml/tint'
    autoload :Shade, 'uniword/drawingml/shade'

    # Shapes & Geometry (9)
    autoload :PresetGeometry, 'uniword/drawingml/preset_geometry'
    autoload :CustomGeometry, 'uniword/drawingml/custom_geometry'
    autoload :AdjustValueList, 'uniword/drawingml/adjust_value_list'
    autoload :GeometryGuide, 'uniword/drawingml/geometry_guide'
    autoload :PathList, 'uniword/drawingml/path_list'
    autoload :MoveTo, 'uniword/drawingml/move_to'
    autoload :LineTo, 'uniword/drawingml/line_to'
    autoload :ArcTo, 'uniword/drawingml/arc_to'
    autoload :ClosePath, 'uniword/drawingml/close_path'

    # 3D Properties (6)
    autoload :Rotation, 'uniword/drawingml/rotation'
    autoload :Camera, 'uniword/drawingml/camera'
    autoload :LightRig, 'uniword/drawingml/light_rig'
    autoload :Scene3D, 'uniword/drawingml/scene_3d'
    autoload :Shape3D, 'uniword/drawingml/shape_3d'
    autoload :BevelTop, 'uniword/drawingml/bevel_top'

    # Theme Components (8) - XML namespace: DrawingML
    autoload :Theme, 'uniword/drawingml/theme'
    autoload :ThemeElements, 'uniword/drawingml/theme'
    autoload :ColorScheme, 'uniword/drawingml/color_scheme'
    autoload :FontScheme, 'uniword/drawingml/font_scheme'
    autoload :FormatScheme, 'uniword/drawingml/format_scheme'
    autoload :FillStyleList, 'uniword/drawingml/format_scheme'
    autoload :LineStyleList, 'uniword/drawingml/format_scheme'
    autoload :EffectStyleList, 'uniword/drawingml/format_scheme'
    autoload :EffectStyle, 'uniword/drawingml/format_scheme'
    autoload :BackgroundFillStyleList, 'uniword/drawingml/format_scheme'
    autoload :ObjectDefaults, 'uniword/drawingml/object_defaults'
    autoload :ShapeDefaults, 'uniword/drawingml/shape_defaults'
    autoload :TextDefaults, 'uniword/drawingml/text_defaults'
    autoload :ExtensionList, 'uniword/drawingml/extension_list'
    autoload :Extension, 'uniword/drawingml/extension'
    autoload :ExtraColorSchemeList, 'uniword/drawingml/extra_color_scheme_list'
  end
end
