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

      # Set text value
      def text=(value)
        self.content = value
      end

      # Check if space should be preserved
      def space_preserve?
        xml_space == 'preserve'
      end

      # Override to_xml to fix the xml:space attribute prefix
      # The serializer outputs w:xml:space but it should be xml:space
      def to_xml(options = {})
        xml = super

        # Fix the attribute name: w:xml:space -> xml:space
        xml.gsub(/w:xml:space=/, 'xml:space=')
      end
    end
  end
end
