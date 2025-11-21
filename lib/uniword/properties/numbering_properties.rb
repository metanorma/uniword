# frozen_string_literal: true

require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Numbering properties (complete numPr structure)
    # Represents paragraph numbering configuration for lists
    class NumberingProperties < Lutaml::Model::Serializable
      xml do
        element 'numPr'
        namespace Ooxml::Namespaces::WordProcessingML

        map_element 'ilvl', to: :level
        map_element 'numId', to: :num_id
        map_element 'numberingChange', to: :numbering_change
        map_element 'ins', to: :inserted_numbering
      end

      # Numbering level (0-8)
      attribute :level, :integer

      # Numbering ID (reference to numbering definition)
      attribute :num_id, :string

      # Numbering change tracking (for track changes)
      attribute :numbering_change, :string

      # Inserted numbering (for track changes)
      attribute :inserted_numbering, :string

      # Convenience method to check if numbering is active
      def active?
        num_id && num_id != '0' && level
      end

      # Convenience method to create numbering properties
      def self.create(num_id, level = 0)
        new(num_id: num_id.to_s, level: level)
      end

      # Convenience method to create bullet numbering
      def self.bullet(level = 0)
        new(num_id: '1', level: level) # Default bullet numbering ID
      end

      # Convenience method to create decimal numbering
      def self.decimal(level = 0)
        new(num_id: '2', level: level) # Default decimal numbering ID
      end

      # Value-based equality
      def ==(other)
        return false unless other.is_a?(self.class)

        level == other.level &&
          num_id == other.num_id &&
          numbering_change == other.numbering_change &&
          inserted_numbering == other.inserted_numbering
      end

      alias eql? ==

      # Hash code for value-based hashing
      def hash
        [level, num_id, numbering_change, inserted_numbering].hash
      end
    end

    # Numbering level properties (for abstract numbering definitions)
    class NumberingLevel < Lutaml::Model::Serializable
      xml do
        element 'lvl'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'ilvl', to: :level_index
        map_element 'start', to: :start
        map_element 'numFmt', to: :number_format
        map_element 'lvlText', to: :level_text
        map_element 'lvlJc', to: :level_justification
        map_element 'pPr', to: :paragraph_properties
        map_element 'rPr', to: :run_properties
        map_element 'lvlPicBulletId', to: :picture_bullet_id
        map_element 'legacy', to: :legacy
        map_element 'isLgl', to: :is_legal
        map_element 'suff', to: :suffix
      end

      # Level index (0-8)
      attribute :level_index, :integer

      # Starting number for this level
      attribute :start, :integer, default: -> { 1 }

      # Number format (decimal, lowerLetter, upperLetter, lowerRoman, upperRoman, bullet, etc.)
      attribute :number_format, :string

      # Level text format (e.g., "%1.", "%1.%2.", "•")
      attribute :level_text, :string

      # Level justification (left, center, right, both, distribute)
      attribute :level_justification, :string

      # Paragraph properties for this level
      attribute :paragraph_properties, :string

      # Run properties for this level
      attribute :run_properties, :string

      # Picture bullet ID (for custom bullets)
      attribute :picture_bullet_id, :string

      # Legacy numbering properties
      attribute :legacy, :string

      # Is legal numbering (for legal documents)
      attribute :is_legal, :boolean, default: -> { false }

      # Suffix character (space, nothing, tab)
      attribute :suffix, :string

      # Convenience method to create a decimal level
      def self.decimal(level_index, start = 1)
        new(
          level_index: level_index,
          start: start,
          number_format: 'decimal',
          level_text: "%#{level_index + 1}."
        )
      end

      # Convenience method to create a bullet level
      def self.bullet(level_index)
        new(
          level_index: level_index,
          number_format: 'bullet',
          level_text: '•'
        )
      end

      # Convenience method to create a letter level
      def self.letter(level_index, upper = false)
        new(
          level_index: level_index,
          number_format: upper ? 'upperLetter' : 'lowerLetter',
          level_text: "%#{level_index + 1}."
        )
      end

      # Convenience method to create a roman numeral level
      def self.roman(level_index, upper = false)
        new(
          level_index: level_index,
          number_format: upper ? 'upperRoman' : 'lowerRoman',
          level_text: "%#{level_index + 1}."
        )
      end

      # Value-based equality
      def ==(other)
        return false unless other.is_a?(self.class)

        level_index == other.level_index &&
          start == other.start &&
          number_format == other.number_format &&
          level_text == other.level_text &&
          level_justification == other.level_justification &&
          paragraph_properties == other.paragraph_properties &&
          run_properties == other.run_properties &&
          picture_bullet_id == other.picture_bullet_id &&
          legacy == other.legacy &&
          is_legal == other.is_legal &&
          suffix == other.suffix
      end

      alias eql? ==

      # Hash code for value-based hashing
      def hash
        [level_index, start, number_format, level_text, level_justification,
         paragraph_properties, run_properties, picture_bullet_id, legacy,
         is_legal, suffix].hash
      end
    end
  end
end