# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Represents a single level in a numbering definition
    # Each level defines format, alignment, indentation, and start value
    class NumberingLevel < Lutaml::Model::Serializable
      attribute :level, :integer, default: -> { 0 }
      attribute :format, :string, default: -> { "decimal" }
      attribute :text, :string
      attribute :start, :integer, default: -> { 1 }
      attribute :alignment, :string, default: -> { "left" }
      attribute :left_indent, :integer, default: -> { 0 }
      attribute :hanging_indent, :integer, default: -> { 0 }
      attribute :font_name, :string
      attribute :font_charset, :string

      # Valid numbering formats
      FORMATS = %w[
        decimal
        upperRoman
        lowerRoman
        upperLetter
        lowerLetter
        ordinal
        cardinalText
        ordinalText
        hex
        chicago
        bullet
      ].freeze

      # Valid alignment values
      ALIGNMENTS = %w[left right center both].freeze

      def initialize(attrs = {})
        super
        validate_format
        validate_alignment
      end

      # Set this level as a bullet with the given character
      def bullet!(character, font_name: "Symbol")
        self.format = "bullet"
        self.text = character
        self.font_name = font_name
      end

      # Check if this is a bullet level
      def bullet?
        format == "bullet"
      end

      # Get the numbering text template
      # Example: "%1." for level 0, "%1.%2." for level 1, etc.
      def numbering_text
        return text if bullet?

        @text || default_numbering_text
      end

      private

      def default_numbering_text
        level_ref = "%#{level + 1}"
        case format
        when "decimal", "upperRoman", "lowerRoman", "upperLetter", "lowerLetter"
          "#{level_ref}."
        else
          level_ref
        end
      end

      def validate_format
        return unless format && !FORMATS.include?(format)

        raise ArgumentError,
              "Invalid format: #{format}. Must be one of: #{FORMATS.join(', ')}"
      end

      def validate_alignment
        return unless alignment && !ALIGNMENTS.include?(alignment)

        raise ArgumentError,
              "Invalid alignment: #{alignment}. Must be one of: #{ALIGNMENTS.join(', ')}"
      end
    end
  end
end
