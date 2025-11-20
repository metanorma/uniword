# frozen_string_literal: true

require_relative 'style'
require_relative 'properties/paragraph_properties'
require_relative 'properties/run_properties'

module Uniword
  # Represents a paragraph style with formatting properties
  # Responsibility: Hold paragraph-specific style properties
  #
  # Paragraph styles define formatting for entire paragraphs,
  # including both paragraph-level properties (alignment, spacing, etc.)
  # and default character properties for runs within the paragraph.
  class ParagraphStyle < Style
    # OOXML namespace configuration
    xml do
      root 'style'
      namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

      map_element 'pPr', to: :paragraph_properties, prefix: 'w', namespace: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
      map_element 'rPr', to: :run_properties, prefix: 'w', namespace: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    end

    # Paragraph-level formatting properties
    attribute :paragraph_properties, Properties::ParagraphProperties

    # Default character formatting for runs in this paragraph
    attribute :run_properties, Properties::RunProperties

    # Initialize a new paragraph style
    #
    # @param attributes [Hash] Style attributes
    def initialize(attributes = {})
      attributes[:type] ||= 'paragraph'
      super
    end

    # Get this style's own properties
    #
    # @return [Hash] Style's own properties
    def own_properties
      {
        paragraph_properties: paragraph_properties,
        run_properties: run_properties
      }
    end

    # Create a default "Normal" style
    #
    # @return [ParagraphStyle] The Normal style
    def self.normal
      new(
        id: 'Normal',
        name: 'Normal',
        type: 'paragraph',
        default: true,
        paragraph_properties: Properties::ParagraphProperties.new(
          spacing_after: 200, # 10pt in twips
          line_spacing: '276', # Single spacing
          alignment: 'left'
        ),
        run_properties: Properties::RunProperties.new(
          size: 22, # 11pt (22 half-points)
          font: 'Calibri'
        )
      )
    end

    # Create a heading style
    #
    # @param level [Integer] Heading level (1-9)
    # @return [ParagraphStyle] The heading style
    def self.heading(level)
      raise ArgumentError, 'Level must be 1-9' unless (1..9).include?(level)

      # Font sizes for headings (in half-points)
      sizes = {
        1 => 32, # 16pt
        2 => 26, # 13pt
        3 => 24, # 12pt
        4 => 22, # 11pt
        5 => 22, # 11pt
        6 => 22, # 11pt
        7 => 22, # 11pt
        8 => 22, # 11pt
        9 => 22  # 11pt
      }

      new(
        id: "Heading#{level}",
        name: "Heading #{level}",
        type: 'paragraph',
        based_on: 'Normal',
        next_style: 'Normal',
        paragraph_properties: Properties::ParagraphProperties.new(
          spacing_before: 200, # 10pt
          spacing_after: 100,  # 5pt
          outline_level: level - 1,
          keep_next: true,
          keep_lines: true
        ),
        run_properties: Properties::RunProperties.new(
          size: sizes[level],
          bold: level <= 3,
          font: 'Calibri'
        )
      )
    end
  end
end