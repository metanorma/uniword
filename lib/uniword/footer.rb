# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  # Represents a document footer
  # Footers can contain paragraphs, tables, and fields (like page numbers)
  class Footer < Lutaml::Model::Serializable
    attribute :type, :string, default: -> { 'default' }
    attribute :paragraphs, Wordprocessingml::Paragraph, collection: true, initialize_empty: true
    attribute :tables, Wordprocessingml::Table, collection: true, initialize_empty: true

    # Valid footer types
    TYPES = %w[default first even].freeze

    def initialize(**attributes)
      super
      @paragraphs ||= []
      @tables ||= []
      validate_type
    end

    # Add a paragraph to this footer
    def add_paragraph(paragraph)
      unless paragraph.is_a?(Wordprocessingml::Paragraph)
        raise ArgumentError,
              'paragraph must be a Paragraph instance'
      end

      paragraphs << paragraph
    end

    # Add a table to this footer
    def add_table(table)
      raise ArgumentError, 'table must be a Wordprocessingml::Table instance' unless table.is_a?(Wordprocessingml::Table)

      tables << table
    end

    # Create and add a text paragraph
    def add_text(text, properties: nil)
      para = Wordprocessingml::Paragraph.new(properties: properties)
      para.add_text(text)
      add_paragraph(para)
      para
    end

    # Add an element (paragraph or table) to footer
    # Compatible with docx-js API
    def add_element(element)
      case element
      when Wordprocessingml::Paragraph
        add_paragraph(element)
      when Wordprocessingml::Table
        add_table(element)
      else
        raise ArgumentError, "Unsupported element type: #{element.class}"
      end
    end

    # Get all content elements (paragraphs and tables) in order
    def elements
      (paragraphs + tables).sort_by do |elem|
        paragraphs.index(elem) || (tables.index(elem) + paragraphs.size)
      end
    end

    # Check if footer is empty
    def empty?
      paragraphs.empty? && tables.empty?
    end

    private

    def validate_type
      return unless type && !TYPES.include?(type)

      raise ArgumentError, "Invalid footer type: #{type}. Must be one of: #{TYPES.join(', ')}"
    end
  end
end
