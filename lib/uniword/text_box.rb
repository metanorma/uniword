# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  # Represents a text box (floating text container)
  # Can be positioned absolutely or relatively
  class TextBox < Lutaml::Model::Serializable
    attribute :paragraphs, Wordprocessingml::Paragraph, collection: true, initialize_empty: true

    # Position (in twips from page origin)
    attribute :x, :integer
    attribute :y, :integer

    # Size (in twips)
    attribute :width, :integer
    attribute :height, :integer

    # Wrapping style
    attribute :wrapping, :string, default: -> { 'square' }

    # Border
    attribute :border_style, :string
    attribute :border_width, :integer
    attribute :border_color, :string

    # Fill
    attribute :fill_color, :string

    # Anchor type (page or paragraph)
    attribute :anchor_type, :string, default: -> { 'page' }

    # Valid wrapping styles
    WRAPPING_STYLES = %w[none square tight through topAndBottom].freeze

    def initialize(**attributes)
      super
      @paragraphs ||= []
      validate_wrapping
    end

    # Add a paragraph to this text box
    def add_paragraph(paragraph)
      unless paragraph.is_a?(Wordprocessingml::Paragraph)
        raise ArgumentError,
              'paragraph must be a Wordprocessingml::Paragraph instance'
      end

      paragraphs << paragraph
    end

    # Create and add a text paragraph
    def add_text(text, properties: nil)
      para = Wordprocessingml::Paragraph.new(properties: properties)
      para.add_text(text)
      add_paragraph(para)
      para
    end

    # Check if text box is empty
    def empty?
      paragraphs.empty?
    end

    private

    def validate_wrapping
      return unless wrapping && !WRAPPING_STYLES.include?(wrapping)

      raise ArgumentError,
            "Invalid wrapping: #{wrapping}. Must be one of: #{WRAPPING_STYLES.join(', ')}"
    end
  end
end
