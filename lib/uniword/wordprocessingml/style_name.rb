# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Style name
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:name>
    class StyleName < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "name"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :val
      end

      # Compare with another StyleName or a string
      def ==(other)
        if other.is_a?(StyleName)
          val == other.val
        elsif other.is_a?(String)
          val == other
        else
          super
        end
      end

      alias eql? ==

      # For string interpolation and general string-like behavior
      def to_s
        val.to_s
      end

      # For hash key compatibility
      def hash
        val.hash
      end
    end
  end
end
