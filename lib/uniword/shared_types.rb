# frozen_string_literal: true

# SharedTypes namespace module
# This file explicitly autoloads all SharedTypes classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# Common value types shared across OOXML namespaces
# Generated from: config/ooxml/schemas/shared_types.yml

require 'lutaml/model'

module Uniword
  module SharedTypes
    # Autoload all SharedTypes classes (15)
    autoload :Angle, 'uniword/shared_types/angle'
    autoload :BooleanValue, 'uniword/shared_types/boolean_value'
    autoload :DecimalNumber, 'uniword/shared_types/decimal_number'
    autoload :EmuMeasure, 'uniword/shared_types/emu_measure'
    autoload :FixedPercentage, 'uniword/shared_types/fixed_percentage'
    autoload :HexColor, 'uniword/shared_types/hex_color'
    autoload :OnOff, 'uniword/shared_types/on_off'
    autoload :PercentValue, 'uniword/shared_types/percent_value'
    autoload :PixelMeasure, 'uniword/shared_types/pixel_measure'
    autoload :PointMeasure, 'uniword/shared_types/point_measure'
    autoload :PositivePercentage, 'uniword/shared_types/positive_percentage'
    autoload :StringType, 'uniword/shared_types/string_type'
    autoload :TextAlignment, 'uniword/shared_types/text_alignment'
    autoload :TwipsMeasure, 'uniword/shared_types/twips_measure'
    autoload :VerticalAlignment, 'uniword/shared_types/vertical_alignment'
  end
end