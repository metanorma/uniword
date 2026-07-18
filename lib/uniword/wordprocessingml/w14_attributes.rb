# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Typed attribute classes for w14/w15/w16 namespace attributes
    # In lutaml-model 0.9.0+, namespace is declared in the xml block, not in map_attribute

    # W14 namespace for Word 2010 elements and attributes
    W14_NAMESPACE = Uniword::Ooxml::Namespaces::Word2010

    # W15 namespace for Word 2012 elements and attributes
    W15_NAMESPACE = Uniword::Ooxml::Namespaces::Word2012

    # W16CID namespace for Word 2016+ citation identifiers
    W16CID_NAMESPACE = Uniword::Ooxml::Namespaces::Word2016Cid

    # ST_LongHexNumber (ECMA-376): exactly 8 hexadecimal digits
    LONG_HEX_NUMBER_PATTERN = /\A[0-9A-Fa-f]{8}\z/

    # Validate an ST_LongHexNumber value at cast time
    #
    # @param value [Object] the raw value
    # @return [String, nil, Object] the validated value
    # @raise [Lutaml::Model::Type::InvalidValueError] when the value is
    #   not 8 hexadecimal digits
    def self.cast_long_hex_number(value)
      casted = Lutaml::Model::Type::String.cast(value)
      return casted if casted.nil? ||
        Lutaml::Model::Utils.uninitialized?(casted)
      return casted if LONG_HEX_NUMBER_PATTERN.match?(casted)

      raise Lutaml::Model::Type::InvalidValueError.new(
        value, ["ST_LongHexNumber: 8 hexadecimal digits"]
      )
    end

    # Typed attribute for w14:paraId (ST_LongHexNumber)
    class W14ParaId < Lutaml::Model::Type::String
      def self.cast(value, _options = {})
        Wordprocessingml.cast_long_hex_number(value)
      end

      xml do
        namespace W14_NAMESPACE
      end
    end

    # Typed attribute for w14:textId (ST_LongHexNumber)
    class W14TextId < Lutaml::Model::Type::String
      def self.cast(value, _options = {})
        Wordprocessingml.cast_long_hex_number(value)
      end

      xml do
        namespace W14_NAMESPACE
      end
    end

    # Typed attribute for w15:restartNumberingAfterBreak
    class W15RestartNumberingAfterBreak < Lutaml::Model::Type::Integer
      xml do
        namespace W15_NAMESPACE
      end
    end

    # Typed attribute for w16cid:durableId
    class W16CidDurableId < Lutaml::Model::Type::String
      xml do
        namespace W16CID_NAMESPACE
      end
    end
  end
end
