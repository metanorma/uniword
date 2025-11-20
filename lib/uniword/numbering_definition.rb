# frozen_string_literal: true

require "lutaml/model"
require_relative "numbering_level"

module Uniword
  # Represents an abstract numbering definition with up to 9 levels (0-8)
  # This is the template that NumberingInstance references
  class NumberingDefinition < Lutaml::Model::Serializable
    attribute :abstract_num_id, :integer
    attribute :levels, NumberingLevel, collection: true, default: -> { [] }
    attribute :name, :string
    attribute :style_link, :string

    MAX_LEVELS = 9

    def initialize(**attributes)
      super
      @levels ||= []
      validate_levels
    end

    # Add a level to this definition
    def add_level(level_obj = nil, **level_attrs)
      if levels.size >= MAX_LEVELS
        raise ArgumentError, "Cannot add more than #{MAX_LEVELS} levels"
      end

      # Auto-assign level index based on position in array
      level_index = levels.size

      if level_obj
        level = level_obj
        level.level = level_index
      else
        level_attrs[:level] = level_index unless level_attrs.key?(:level)
        level = NumberingLevel.new(**level_attrs)
      end

      levels << level
      level
    end

    # Get a specific level by index
    def level(index)
      levels[index]
    end

    # Create a simple decimal numbering definition
    def self.decimal(abstract_num_id:, name: "Decimal")
      new(abstract_num_id: abstract_num_id, name: name).tap do |defn|
        9.times do |i|
          defn.add_level(
            level: i,
            format: "decimal",
            start: 1,
            alignment: "left",
            left_indent: 720 * (i + 1),
            hanging_indent: 360
          )
        end
      end
    end

    # Create a bullet numbering definition
    def self.bullet(abstract_num_id:, name: "Bullet", character: "\u2022")
      new(abstract_num_id: abstract_num_id, name: name).tap do |defn|
        9.times do |i|
          level_char = case i % 3
                       when 0 then character
                       when 1 then "\u25CB" # hollow circle
                       else "\u25A0" # square
                       end

          defn.add_level(
            level: i,
            format: "bullet",
            text: level_char,
            font_name: "Symbol",
            alignment: "left",
            left_indent: 720 * (i + 1),
            hanging_indent: 360
          )
        end
      end
    end

    # Create a roman numeral numbering definition
    def self.roman(abstract_num_id:, name: "Roman", upper: true)
      format = upper ? "upperRoman" : "lowerRoman"
      new(abstract_num_id: abstract_num_id, name: name).tap do |defn|
        9.times do |i|
          defn.add_level(
            level: i,
            format: format,
            start: 1,
            alignment: "left",
            left_indent: 720 * (i + 1),
            hanging_indent: 360
          )
        end
      end
    end

    # Create a letter numbering definition
    def self.letter(abstract_num_id:, name: "Letter", upper: true)
      format = upper ? "upperLetter" : "lowerLetter"
      new(abstract_num_id: abstract_num_id, name: name).tap do |defn|
        9.times do |i|
          defn.add_level(
            level: i,
            format: format,
            start: 1,
            alignment: "left",
            left_indent: 720 * (i + 1),
            hanging_indent: 360
          )
        end
      end
    end

    private

    def validate_levels
      return if levels.size <= MAX_LEVELS

      raise ArgumentError, "NumberingDefinition cannot have more than #{MAX_LEVELS} levels"
    end
  end
end