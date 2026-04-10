# frozen_string_literal: true

require 'lutaml/model'
# NumberingLevel is autoloaded via lib/uniword/wordprocessingml.rb

module Uniword
  module Wordprocessingml
    # Represents an abstract numbering definition with up to 9 levels (0-8)
    # This is the template that NumberingInstance references
    #
    # Represents <w:abstractNum w:abstractNumId="..."> element
    class NumberingDefinition < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :abstract_num_id, :integer
      attribute :restart_numbering_after_break, W15RestartNumberingAfterBreak
      attribute :nsid, Nsid
      attribute :multi_level_type, MultiLevelType
      attribute :tmpl, Tmpl
      attribute :levels, Level, collection: true, initialize_empty: true
      attribute :name, :string
      attribute :style_link, :string

      # XML mappings come AFTER attributes
      xml do
        element 'abstractNum'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'abstractNumId', to: :abstract_num_id
        # w15:restartNumberingAfterBreak - typed attribute with namespace
        map_attribute 'restartNumberingAfterBreak', to: :restart_numbering_after_break,
                                                    render_nil: false
        map_element 'nsid', to: :nsid, render_nil: false
        map_element 'multiLevelType', to: :multi_level_type, render_nil: false
        map_element 'tmpl', to: :tmpl, render_nil: false
        map_element 'lvl', to: :levels, render_nil: false
        # name and style_link map to child elements
      end

      MAX_LEVELS = 9

      def initialize(attrs = {})
        super
        @levels ||= []
        validate_levels
      end

      # Add a level to this definition
      def add_level(level_obj = nil, **level_attrs)
        if levels.size >= MAX_LEVELS
          raise ArgumentError,
                "Cannot add more than #{MAX_LEVELS} levels"
        end

        # Auto-assign level index based on position in array
        level_index = levels.size

        if level_obj
          level = level_obj
          level.ilvl = level_index
        else
          level_attrs[:ilvl] = level_index unless level_attrs.key?(:ilvl)
          level = Level.new(**level_attrs)
        end

        levels << level
        level
      end

      # Get a specific level by index
      def level(index)
        levels[index]
      end

      # Create a simple decimal numbering definition
      def self.decimal(abstract_num_id:, name: 'Decimal')
        new(abstract_num_id: abstract_num_id, name: name).tap do |defn|
          9.times do |i|
            defn.add_level(
              ilvl: i,
              start: Uniword::Wordprocessingml::Start.new(val: 1),
              numFmt: Uniword::Wordprocessingml::NumFmt.new(val: 'decimal'),
              lvlJc: Uniword::Wordprocessingml::LvlJc.new(val: 'left'),
              ind: Uniword::Wordprocessingml::Ind.new(left: (720 * (i + 1)).to_s, hanging: '360')
            )
          end
        end
      end

      # Create a bullet numbering definition
      def self.bullet(abstract_num_id:, name: 'Bullet', character: "\u2022")
        new(abstract_num_id: abstract_num_id, name: name).tap do |defn|
          9.times do |i|
            level_char = case i % 3
                         when 0 then character
                         when 1 then "\u25CB" # hollow circle
                         else "\u25A0" # square
                         end

            defn.add_level(
              ilvl: i,
              start: Uniword::Wordprocessingml::Start.new(val: 1),
              numFmt: Uniword::Wordprocessingml::NumFmt.new(val: 'bullet'),
              lvlText: Uniword::Wordprocessingml::LvlText.new(val: level_char),
              lvlJc: Uniword::Wordprocessingml::LvlJc.new(val: 'left'),
              ind: Uniword::Wordprocessingml::Ind.new(left: (720 * (i + 1)).to_s, hanging: '360'),
              rPr: Uniword::Wordprocessingml::RunProperties.new(
                fonts: Properties::RunFonts.new(ascii: 'Symbol', h_ansi: 'Symbol', hint: 'default')
              )
            )
          end
        end
      end

      # Create a roman numeral numbering definition
      def self.roman(abstract_num_id:, name: 'Roman', upper: true)
        format = upper ? 'upperRoman' : 'lowerRoman'
        new(abstract_num_id: abstract_num_id, name: name).tap do |defn|
          9.times do |i|
            defn.add_level(
              ilvl: i,
              start: Uniword::Wordprocessingml::Start.new(val: 1),
              numFmt: Uniword::Wordprocessingml::NumFmt.new(val: format),
              lvlJc: Uniword::Wordprocessingml::LvlJc.new(val: 'left'),
              ind: Uniword::Wordprocessingml::Ind.new(left: (720 * (i + 1)).to_s, hanging: '360')
            )
          end
        end
      end

      # Create a letter numbering definition
      def self.letter(abstract_num_id:, name: 'Letter', upper: true)
        format = upper ? 'upperLetter' : 'lowerLetter'
        new(abstract_num_id: abstract_num_id, name: name).tap do |defn|
          9.times do |i|
            defn.add_level(
              ilvl: i,
              start: Uniword::Wordprocessingml::Start.new(val: 1),
              numFmt: Uniword::Wordprocessingml::NumFmt.new(val: format),
              lvlJc: Uniword::Wordprocessingml::LvlJc.new(val: 'left'),
              ind: Uniword::Wordprocessingml::Ind.new(left: (720 * (i + 1)).to_s, hanging: '360')
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
end
