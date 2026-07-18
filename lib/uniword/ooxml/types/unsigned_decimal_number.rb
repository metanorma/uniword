# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # ST_UnsignedDecimalNumber (ECMA-376): non-negative integer
      #
      # Constrained integer type shared by unsigned OOXML measures
      # (ST_TwipsMeasure, ST_PointMeasure, ST_PixelsMeasure). Negative
      # values raise Lutaml::Model::Type::MinBoundError at cast time
      # (attribute assignment and XML parsing).
      class UnsignedDecimalNumber < Lutaml::Model::Type::Integer
        # Cast a value to a non-negative Integer
        #
        # @param value [Object] the raw value
        # @param options [Hash] cast options (unused)
        # @return [Integer, nil] the non-negative integer value
        # @raise [Lutaml::Model::Type::MinBoundError] when negative
        def self.cast(value, options = {})
          casted = super
          return casted unless casted.is_a?(::Integer) && casted.negative?

          raise Lutaml::Model::Type::MinBoundError.new(casted, 0)
        end
      end
    end
  end
end
