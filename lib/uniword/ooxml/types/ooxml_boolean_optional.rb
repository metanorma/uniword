# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # OOXML Boolean type for optional attributes (nil-omitting)
      #
      # Key behavior:
      # - cast(nil) -> nil (doesn't convert to false like OoxmlBoolean)
      # - cast("1"/"true"/"on") -> true, cast("0"/"false"/"off") -> false
      # - cast of any other value raises
      #   Lutaml::Model::Type::InvalidValueError instead of passing
      #   through unchanged
      # - to_xml(true) -> "1"
      # - to_xml(false) -> "0" (explicit false in original)
      # - to_xml(nil) -> nil (attribute absent, omit from output)
      #
      # This is the right type for attributes like w:locked, w:semiHidden
      # on lsdException where absent = false = omit, but explicit
      # "0" = render "0".
      # Note: Due to cast(nil) = nil, absent attributes also serialize
      # as omitted.
      class OoxmlBooleanOptional < Lutaml::Model::Type::Boolean
        def self.cast(value, _options = {})
          return value if Lutaml::Model::Utils.uninitialized?(value)
          return nil if value.nil?
          return true if OoxmlBoolean::TRUE_VALUES.include?(value)
          return false if OoxmlBoolean::FALSE_VALUES.include?(value)

          raise Lutaml::Model::Type::InvalidValueError.new(
            value, OoxmlBoolean::ON_OFF_VALUES
          )
        end

        def self.serialize(value)
          return nil if value.nil?
          return "1" if OoxmlBoolean::TRUE_VALUES.include?(value)
          return "0" if OoxmlBoolean::FALSE_VALUES.include?(value)

          raise Lutaml::Model::Type::InvalidValueError.new(
            value, OoxmlBoolean::ON_OFF_VALUES
          )
        end

        # Override instance to_xml:
        # - true -> "1"
        # - false -> "0"
        # - nil -> nil (omitted)
        def to_xml
          case @value
          when true
            "1"
          when false
            "0"
          end
        end
      end
    end
  end
end
