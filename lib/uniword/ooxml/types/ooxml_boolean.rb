# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # OOXML Boolean type for attributes (ST_OnOff, ECMA-376)
      # OOXML uses "1"/"0" encoding for boolean attributes; ST_OnOff also
      # accepts the xsd:boolean spellings "true"/"false" and "on"/"off".
      #
      # Parsing: "1"/"true"/"on" -> true, "0"/"false"/"off"/nil -> false
      # Serialization: true -> "1", false -> "0"
      # Serializing anything else raises
      # Lutaml::Model::Type::InvalidValueError, because a value the program
      # set is a bug rather than a document we were handed.
      class OoxmlBoolean < Lutaml::Model::Type::Boolean
        # Accepted ST_OnOff spellings for Boolean true
        TRUE_VALUES = [true, 1, "1", "true", "on"].freeze

        # Accepted ST_OnOff spellings for Boolean false
        FALSE_VALUES = [false, 0, "0", "false", "off"].freeze

        # All accepted ST_OnOff spellings
        ON_OFF_VALUES = (TRUE_VALUES + FALSE_VALUES).freeze

        # The one ST_OnOff reading, shared by these attribute types and by
        # Properties::BooleanElement.
        #
        # A reader must not raise on a malformed document. One bad token in
        # styles.xml used to kill the whole parse, and a token outside the
        # vocabulary is not an off token, so it reads as on — the same way an
        # unrecognised w:val does.
        #
        # @param value [Object] Raw ST_OnOff token
        # @return [Boolean] true when the toggle is on
        def self.on?(value)
          !FALSE_VALUES.include?(value)
        end

        def self.cast(value, _options = {})
          return value if Lutaml::Model::Utils.uninitialized?(value)
          return false if value.nil?

          on?(value)
        end

        def self.serialize(value)
          return nil if value.nil?
          return "1" if TRUE_VALUES.include?(value)
          return "0" if FALSE_VALUES.include?(value)

          raise Lutaml::Model::Type::InvalidValueError.new(
            value, ON_OFF_VALUES
          )
        end

        # Override instance to_xml for OOXML boolean serialization
        # Parent class returns value.to_s which gives "true"/"false"
        # OOXML requires "1"/"0" for boolean attributes
        def to_xml
          case @value
          when true
            "1"
          when false
            "0"
          else
            @value.to_s
          end
        end
      end
    end
  end
end
