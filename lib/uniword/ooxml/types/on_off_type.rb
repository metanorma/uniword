# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # OOXML On/Off (boolean) type for attributes.
      #
      # OOXML uses "0" and "1" for boolean attribute values, not "false"/"true".
      # When an attribute is not present (nil), it should remain nil, not be
      # serialized as "0". This preserves the original document structure.
      #
      # @example Serialize a boolean attribute
      #   # Ruby true → XML "1"
      #   # Ruby false → XML "0"
      #   # Ruby nil → attribute not rendered
      class OnOffType < Lutaml::Model::Type::String
        # Bypass parent's initialize to avoid infinite recursion.
        # Parent calls self.class.cast(value) which calls self.new(value).
        def initialize(value)
          @value = value
        end

        # Cast value to OnOffType instance (for attribute serialization).
        # nil remains nil (not present in source), preserving original structure.
        # Already-wrapped OnOffType instances are returned as-is.
        def self.cast(value, _options = {})
          return nil if value.nil?
          return value if value.is_a?(OnOffType)

          raw = case value
                when true, "true", "1", 1
                  true
                when false, "false", "0", 0
                  false
                else
                  false
                end
          new(raw)
        end

        # Convert stored boolean to OOXML "1" or "0"
        def to_xml
          return nil if @value.nil?

          @value == true ? "1" : "0"
        end

        # Fallback to_s also returns "1"/"0" for compatibility
        def to_s
          return "" if @value.nil?

          to_xml
        end

        # Return the raw boolean value for Ruby comparisons
        def to_bool
          @value == true
        end
      end
    end
  end
end
