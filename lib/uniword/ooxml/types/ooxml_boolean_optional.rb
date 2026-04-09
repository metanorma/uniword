# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Ooxml
    module Types
      # OOXML Boolean type for optional attributes (nil-omitting)
      #
      # Key behavior:
      # - cast(nil) -> nil (doesn't convert to false like OoxmlBoolean)
      # - cast("1") -> true, cast("0") -> false
      # - to_xml(true) -> "1"
      # - to_xml(false) -> "0" (explicit false in original)
      # - to_xml(nil) -> nil (attribute absent, omit from output)
      #
      # This is the right type for attributes like w:locked, w:semiHidden
      # on lsdException where absent = false = omit, but explicit "0" = render "0".
      # Note: Due to cast(nil) = nil, absent attributes also serialize as omitted.
      class OoxmlBooleanOptional < Lutaml::Model::Type::Boolean
        def self.cast(value, _options = {})
          case value
          when true, '1', 1
            true
          when false, '0', 0
            false
          when nil
            nil
          else
            value
          end
        end

        def self.serialize(value)
          return nil if value.nil?
          return '1' if value == true || value.to_s.match?(/^(true|t|yes|y|1)$/i)
          return '0' if value == false || value.to_s.match?(/^(false|f|no|n|0)$/i)

          value
        end

        # Override instance to_xml:
        # - true -> "1"
        # - false -> "0"
        # - nil -> nil (omitted)
        def to_xml
          case @value
          when true
            '1'
          when false
            '0'
          else
            nil
          end
        end
      end
    end
  end
end
