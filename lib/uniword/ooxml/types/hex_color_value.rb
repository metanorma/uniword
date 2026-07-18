# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # ST_HexColor (ECMA-376): RGB hex color or "auto"
      #
      # Constrained string type: six hexadecimal digits (case-insensitive,
      # ST_HexColorRGB) or the literal "auto" (ST_HexColorAuto). Invalid
      # values raise Lutaml::Model::Type::InvalidValueError at cast time
      # (attribute assignment and XML parsing).
      class HexColorValue < Lutaml::Model::Type::String
        # ST_HexColor value shape: "auto" or RRGGBB hex digits
        HEX_COLOR_PATTERN = /\A(?:auto|[0-9A-Fa-f]{6})\z/

        # Cast a value to a valid ST_HexColor string
        #
        # @param value [Object] the raw value
        # @param options [Hash] cast options (unused)
        # @return [String, nil] the validated color string
        # @raise [Lutaml::Model::Type::InvalidValueError] when the value
        #   is neither "auto" nor six hex digits
        def self.cast(value, options = {})
          casted = super
          return casted if casted.nil? ||
            Lutaml::Model::Utils.uninitialized?(casted)
          return casted if HEX_COLOR_PATTERN.match?(casted)

          raise Lutaml::Model::Type::InvalidValueError.new(
            value, ["auto", "RRGGBB (6 hexadecimal digits)"]
          )
        end
      end
    end
  end
end
