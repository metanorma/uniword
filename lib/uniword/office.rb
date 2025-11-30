# frozen_string_literal: true

# Office namespace
# Word-specific extensions and legacy features
# Namespace: urn:schemas-microsoft-com:office:office
# Prefix: o:

module Uniword
  module Office
    autoload :Bottom, File.expand_path('office/bottom', __dir__)
    autoload :Brightness, File.expand_path('office/brightness', __dir__)
    autoload :Button, File.expand_path('office/button', __dir__)
    autoload :Callout, File.expand_path('office/callout', __dir__)
    autoload :CalloutAnchor, File.expand_path('office/callout_anchor', __dir__)
    autoload :Checkbox, File.expand_path('office/checkbox', __dir__)
    autoload :ColorMenu, File.expand_path('office/color_menu', __dir__)
    autoload :ColorMru, File.expand_path('office/color_mru', __dir__)
    autoload :Complex, File.expand_path('office/complex', __dir__)
    autoload :Diagram, File.expand_path('office/diagram', __dir__)
    autoload :Diffusity, File.expand_path('office/diffusity', __dir__)
    autoload :DocumentProtection, File.expand_path('office/document_protection', __dir__)
    autoload :DocumentView, File.expand_path('office/document_view', __dir__)
    autoload :Edge, File.expand_path('office/edge', __dir__)
    autoload :Extrusion, File.expand_path('office/extrusion', __dir__)
    autoload :ExtrusionColor, File.expand_path('office/extrusion_color', __dir__)
    autoload :ExtrusionColorMode, File.expand_path('office/extrusion_color_mode', __dir__)
    autoload :ExtrusionOk, File.expand_path('office/extrusion_ok', __dir__)
    autoload :Field, File.expand_path('office/field', __dir__)
    autoload :Forms, File.expand_path('office/forms', __dir__)
    autoload :IdMap, File.expand_path('office/id_map', __dir__)
    autoload :Ink, File.expand_path('office/ink', __dir__)
    autoload :InkAnnotation, File.expand_path('office/ink_annotation', __dir__)
    autoload :Left, File.expand_path('office/left', __dir__)
    autoload :Lock, File.expand_path('office/lock', __dir__)
    autoload :Metal, File.expand_path('office/metal', __dir__)
    autoload :ProofState, File.expand_path('office/proof_state', __dir__)
    autoload :Regroup, File.expand_path('office/regroup', __dir__)
    autoload :RegroupTable, File.expand_path('office/regroup_table', __dir__)
    autoload :RelationTable, File.expand_path('office/relation_table', __dir__)
    autoload :Right, File.expand_path('office/right', __dir__)
    autoload :Rules, File.expand_path('office/rules', __dir__)
    autoload :ShapeDefaults, File.expand_path('office/shape_defaults', __dir__)
    autoload :ShapeLayout, File.expand_path('office/shape_layout', __dir__)
    autoload :SignatureLine, File.expand_path('office/signature_line', __dir__)
    autoload :Skew, File.expand_path('office/skew', __dir__)
    autoload :Specularity, File.expand_path('office/specularity', __dir__)
    autoload :Top, File.expand_path('office/top', __dir__)
    autoload :WritingStyle, File.expand_path('office/writing_style', __dir__)
    autoload :Zoom, File.expand_path('office/zoom', __dir__)
  end
end
