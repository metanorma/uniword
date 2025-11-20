# frozen_string_literal: true

require_relative 'style'
require_relative 'properties/run_properties'

module Uniword
  # Represents a character style with formatting properties
  # Responsibility: Hold character-specific style properties
  #
  # Character styles define formatting for text runs (inline text),
  # including font, size, color, bold, italic, underline, etc.
  class CharacterStyle < Style
    # OOXML namespace configuration
    xml do
      root 'style'
      namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

      map_element 'rPr', to: :run_properties, prefix: 'w', namespace: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    end

    # Character formatting properties
    attribute :run_properties, Properties::RunProperties

    # Initialize a new character style
    #
    # @param attributes [Hash] Style attributes
    def initialize(attributes = {})
      attributes[:type] ||= 'character'
      super
    end

    # Get this style's own properties
    #
    # @return [Hash] Style's own properties
    def own_properties
      {
        run_properties: run_properties
      }
    end

    # Create a default character style
    #
    # @return [CharacterStyle] The default character style
    def self.default_char
      new(
        id: 'DefaultParagraphFont',
        name: 'Default Paragraph Font',
        type: 'character',
        default: true,
        run_properties: Properties::RunProperties.new(
          size: 22,
          font: 'Calibri'
        )
      )
    end

    # Create an emphasis (italic) style
    #
    # @return [CharacterStyle] The emphasis style
    def self.emphasis
      new(
        id: 'Emphasis',
        name: 'Emphasis',
        type: 'character',
        run_properties: Properties::RunProperties.new(
          italic: true
        )
      )
    end

    # Create a strong (bold) style
    #
    # @return [CharacterStyle] The strong style
    def self.strong
      new(
        id: 'Strong',
        name: 'Strong',
        type: 'character',
        run_properties: Properties::RunProperties.new(
          bold: true
        )
      )
    end
  end
end