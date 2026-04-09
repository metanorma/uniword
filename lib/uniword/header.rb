# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  # Represents a document header
  # Headers can contain paragraphs and tables
  class Header < Lutaml::Model::Serializable
    attribute :type, :string, default: -> { 'default' }
    attribute :paragraphs, Wordprocessingml::Paragraph, collection: true, initialize_empty: true
    attribute :tables, Wordprocessingml::Table, collection: true, initialize_empty: true

    # Valid header types
    TYPES = %w[default first even].freeze

    def initialize(**attributes)
      super
      validate_type
    end

    # Get all content elements (paragraphs and tables) in order
    def elements
      (paragraphs + tables).sort_by do |elem|
        paragraphs.index(elem) || (tables.index(elem) + paragraphs.size)
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
