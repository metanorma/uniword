# frozen_string_literal: true

require 'lutaml/model'
require 'nokogiri'

module Uniword
  module Wordprocessingml
    # Text content with xml:space attribute support
    #
    # Element: <w:t xml:space="preserve">
    class Text < Lutaml::Model::Serializable
      attribute :content, :string
      attribute :xml_space, :string

      xml do
        element 't'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_content to: :content
        map_attribute 'xml:space', to: :xml_space
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

      # Set text value
      def text=(value)
        self.content = value
      end

      # Check if space should be preserved
      def space_preserve?
        xml_space == 'preserve'
      end
    end
  end
end
