# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Style reference element for paragraph styles
    #
    # Represents <w:pStyle w:val="..."/> where value is the style ID
    class StyleReference < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element "pStyle"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :value
      end

      # Compare with another StyleReference or a string
      def ==(other)
        if other.is_a?(StyleReference)
          value == other.value
        elsif other.is_a?(String)
          value == other
        else
          super
        end
      end

      alias eql? ==

      # For string interpolation and general string-like behavior
      def to_s
        value.to_s
      end

      # For hash key compatibility
      def hash
        value.hash
      end
    end

    # Style reference element for character/run styles
    #
    # Represents <w:rStyle w:val="..."/> where value is the style ID
    class RunStyleReference < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element "rStyle"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :value
      end

      # Compare with another RunStyleReference or a string
      def ==(other)
        if other.is_a?(RunStyleReference)
          value == other.value
        elsif other.is_a?(String)
          value == other
        else
          super
        end
      end

      alias eql? ==

      # For string interpolation and general string-like behavior
      def to_s
        value.to_s
      end

      # For hash key compatibility
      def hash
        value.hash
      end
    end
  end
end
