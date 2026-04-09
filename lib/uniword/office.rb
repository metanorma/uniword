# frozen_string_literal: true

# Office namespace module
# This file explicitly autoloads all Office classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# Office namespace - Word-specific extensions and legacy features
# Namespace: urn:schemas-microsoft-com:office:office
# Prefix: o:

require 'lutaml/model'

module Uniword
  module Office
    # Autoload all Office classes (40)
    autoload :Bottom, 'uniword/office/bottom'
    autoload :Brightness, 'uniword/office/brightness'
    autoload :Button, 'uniword/office/button'
    autoload :Callout, 'uniword/office/callout'
    autoload :CalloutAnchor, 'uniword/office/callout_anchor'
    autoload :Checkbox, 'uniword/office/checkbox'
    autoload :ColorMenu, 'uniword/office/color_menu'
    autoload :ColorMru, 'uniword/office/color_mru'
    autoload :Complex, 'uniword/office/complex'
    autoload :Diagram, 'uniword/office/diagram'
    autoload :Diffusity, 'uniword/office/diffusity'
    autoload :DocumentProtection, 'uniword/office/document_protection'
    autoload :DocumentView, 'uniword/office/document_view'
    autoload :Edge, 'uniword/office/edge'
    autoload :Extrusion, 'uniword/office/extrusion'
    autoload :ExtrusionColor, 'uniword/office/extrusion_color'
    autoload :ExtrusionColorMode, 'uniword/office/extrusion_color_mode'
    autoload :ExtrusionOk, 'uniword/office/extrusion_ok'
    autoload :Field, 'uniword/office/field'
    autoload :Forms, 'uniword/office/forms'
    autoload :IdMap, 'uniword/office/id_map'
    autoload :Ink, 'uniword/office/ink'
    autoload :InkAnnotation, 'uniword/office/ink_annotation'
    autoload :Left, 'uniword/office/left'
    autoload :Lock, 'uniword/office/lock'
    autoload :Metal, 'uniword/office/metal'
    autoload :ProofState, 'uniword/office/proof_state'
    autoload :Regroup, 'uniword/office/regroup'
    autoload :RegroupTable, 'uniword/office/regroup_table'
    autoload :RelationTable, 'uniword/office/relation_table'
    autoload :Right, 'uniword/office/right'
    autoload :Rules, 'uniword/office/rules'
    autoload :ShapeDefaults, 'uniword/office/shape_defaults'
    autoload :ShapeLayout, 'uniword/office/shape_layout'
    autoload :SignatureLine, 'uniword/office/signature_line'
    autoload :Skew, 'uniword/office/skew'
    autoload :Specularity, 'uniword/office/specularity'
    autoload :Top, 'uniword/office/top'
    autoload :WritingStyle, 'uniword/office/writing_style'
    autoload :Zoom, 'uniword/office/zoom'
  end
end
