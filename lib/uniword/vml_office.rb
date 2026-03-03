# frozen_string_literal: true

# VmlOffice namespace module
# This file explicitly autoloads all VmlOffice classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# VML Office - Office-specific VML extensions
# Namespace: urn:schemas-microsoft-com:office:office
# Prefix: o: (within VML context)

require 'lutaml/model'

module Uniword
  module VmlOffice
    # Autoload all VmlOffice classes (25)
    autoload :VmlAnchorLock, 'uniword/vml_office/vml_anchor_lock'
    autoload :VmlBottom, 'uniword/vml_office/vml_bottom'
    autoload :VmlClipPath, 'uniword/vml_office/vml_clip_path'
    autoload :VmlColorMru, 'uniword/vml_office/vml_color_mru'
    autoload :VmlColumn, 'uniword/vml_office/vml_column'
    autoload :VmlComplex, 'uniword/vml_office/vml_complex'
    autoload :VmlComplexExtension, 'uniword/vml_office/vml_complex_extension'
    autoload :VmlDiagram, 'uniword/vml_office/vml_diagram'
    autoload :VmlEntry, 'uniword/vml_office/vml_entry'
    autoload :VmlIdMap, 'uniword/vml_office/vml_id_map'
    autoload :VmlInk, 'uniword/vml_office/vml_ink'
    autoload :VmlLeft, 'uniword/vml_office/vml_left'
    autoload :VmlOfficeFill, 'uniword/vml_office/vml_office_fill'
    autoload :VmlProxy, 'uniword/vml_office/vml_proxy'
    autoload :VmlRegroup, 'uniword/vml_office/vml_regroup'
    autoload :VmlRelationTable, 'uniword/vml_office/vml_relation_table'
    autoload :VmlRight, 'uniword/vml_office/vml_right'
    autoload :VmlRule, 'uniword/vml_office/vml_rule'
    autoload :VmlRules, 'uniword/vml_office/vml_rules'
    autoload :VmlShapeDefaults, 'uniword/vml_office/vml_shape_defaults'
    autoload :VmlShapeLayout, 'uniword/vml_office/vml_shape_layout'
    autoload :VmlSignatureLine, 'uniword/vml_office/vml_signature_line'
    autoload :VmlTop, 'uniword/vml_office/vml_top'
    autoload :VmlWrapBlock, 'uniword/vml_office/vml_wrap_block'
    autoload :VmlWrapCoords, 'uniword/vml_office/vml_wrap_coords'
  end
end
