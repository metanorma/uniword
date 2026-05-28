# frozen_string_literal: true

require "lutaml/model"
require "nokogiri"

module Uniword
  module Wordprocessingml
    # Text content with xml:space attribute support
    #
    # Element: <w:t xml:space="preserve">
    class Text < Lutaml::Model::Serializable
      attribute :content, :string
      attribute :xml_space, :string

      xml do
        element "t"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_content to: :content
        map_attribute "xml:space", to: :xml_space
      end

      # Handle type conversion for lutaml-model's attribute system.
      # When used as an attribute type, lutaml-model calls cast() to convert
      # incoming values to the proper type.
      #
      # @param value [String, Text, nil] The value to cast
      # @return [Text, nil] The properly typed Text object
      def self.cast(value)
        case value
        when Text
          value
        when nil
          nil
        else
          content_str = value.to_s
          text_obj = new(content: content_str)
          text_obj.xml_space = "preserve" if preserve_whitespace?(content_str)
          text_obj
        end
      end

      # Whether the content requires xml:space="preserve" per OOXML spec.
      # Leading/trailing spaces, tabs, and newlines all need preservation.
      def self.preserve_whitespace?(content)
        content.start_with?(" ") || content.end_with?(" ") ||
          content.include?("\t") || content.include?("\n")
      end

      # Get the actual text value
      def text
        content
      end

      # String conversion for compatibility with code expecting plain strings
      def to_s
        content.to_s
      end

      # Allow comparison with strings for test compatibility
      def ==(other)
        return super unless other.is_a?(String)

        content == other
      end

      alias eql? ==

      # Support String#include? for test compatibility
      def include?(substr)
        content.to_s.include?(substr)
      end

      # Check if space should be preserved
      def space_preserve?
        xml_space == "preserve"
      end
    end
  end
end
