# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  # Represents a text element (w:t) in OOXML
  # Responsibility: Wrap text content with proper XML serialization
  #
  # The text element is the lowest-level container for text content in OOXML.
  # It handles the xml:space attribute for whitespace preservation.
  class TextElement < Lutaml::Model::Serializable
    # OOXML namespace configuration
    xml do
      root 't'
      namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

      map_content to: :content
      map_attribute 'space', to: :space, namespace: 'http://www.w3.org/XML/1998/namespace', prefix: 'xml'
    end

    # The text content
    attribute :content, :string

    # XML space preservation attribute
    # Set to "preserve" when text has leading/trailing whitespace
    attribute :space, :string

    # Create a new TextElement
    #
    # @param attributes [Hash] Initial attributes
    # @option attributes [String] :content The text content
    # @option attributes [String] :space XML space attribute (usually "preserve")
    def initialize(attributes = {})
      super
      # Auto-set xml:space="preserve" if text has leading/trailing whitespace
      if content && (content.start_with?(' ') || content.end_with?(' '))
        self.space ||= 'preserve'
      end
    end

    # Check if element is empty
    #
    # @return [Boolean] true if content is nil or empty
    def empty?
      content.nil? || content.empty?
    end

    # Convert to string
    #
    # @return [String] The text content
    def to_s
      content.to_s
    end
  end
end