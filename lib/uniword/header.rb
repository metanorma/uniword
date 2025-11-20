# frozen_string_literal: true

require "lutaml/model"

module Uniword
  # Represents a document header
  # Headers can contain paragraphs and tables
  class Header < Lutaml::Model::Serializable
    attribute :type, :string, default: -> { "default" }
    attribute :paragraphs, Paragraph, collection: true, default: -> { [] }
    attribute :tables, Table, collection: true, default: -> { [] }

    # Valid header types
    TYPES = %w[default first even].freeze

    def initialize(**attributes)
      super
      @paragraphs ||= []
      @tables ||= []
      validate_type
    end

    # Add a paragraph to this header
    def add_paragraph(paragraph)
      raise ArgumentError, 'paragraph must be a Paragraph instance' unless paragraph.is_a?(Paragraph)

      paragraphs << paragraph
    end

    # Add a table to this header
    def add_table(table)
      raise ArgumentError, 'table must be a Table instance' unless table.is_a?(Table)

      tables << table
    end

    # Create and add a text paragraph
    def add_text(text, properties: nil)
      para = Paragraph.new(properties: properties)
      para.add_text(text)
      add_paragraph(para)
      para
    end

    # Add an element (paragraph or table) to header
    # Compatible with docx-js API
    def add_element(element)
      case element
      when Paragraph
        add_paragraph(element)
      when Table
        add_table(element)
      else
        raise ArgumentError, "Unsupported element type: #{element.class}"
      end
    end

    # Get all content elements (paragraphs and tables) in order
    def elements
      (paragraphs + tables).sort_by do |elem|
        paragraphs.index(elem) || tables.index(elem) + paragraphs.size
      end
    end

    # Check if header is empty
    def empty?
      paragraphs.empty? && tables.empty?
    end

    private

    def validate_type
      return unless type && !TYPES.include?(type)

      raise ArgumentError, "Invalid header type: #{type}. Must be one of: #{TYPES.join(', ')}"
    end
  end
end