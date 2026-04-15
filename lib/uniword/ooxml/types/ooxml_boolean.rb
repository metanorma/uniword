# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # OOXML Boolean type for attributes
      # OOXML uses "1"/"0" encoding for boolean attributes, not "true"/"false"
      #
      # Parsing: "1" -> true, "0" -> false
      # Serialization: true -> "1", false -> "0"
      class OoxmlBoolean < Lutaml::Model::Type::Boolean
        def self.cast(value, _options = {})
          case value
          when true, "1", 1
            true
          when false, "0", 0, nil
            false
          else
            value
          end
        end

        def self.serialize(value)
          return nil if value.nil?
          return "1" if value == true || value.to_s.match?(/^(true|t|yes|y|1)$/i)
          return "0" if value == false || value.to_s.match?(/^(false|f|no|n|0)$/i)

          value
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
