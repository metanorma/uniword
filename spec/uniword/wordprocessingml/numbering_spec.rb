# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Numbering Feature' do
  describe Uniword::Wordprocessingml::NumberingLevel do
    describe '#initialize' do
      it 'creates a level with default values' do
        level = Uniword::Wordprocessingml::NumberingLevel.new
        expect(level.level).to eq(0)
        expect(level.format).to eq('decimal')
        expect(level.start).to eq(1)
        expect(level.alignment).to eq('left')
      end

      it 'creates a level with custom values' do
        level = Uniword::Wordprocessingml::NumberingLevel.new(
          level: 2,
          format: 'upperRoman',
          start: 5,
          alignment: 'right',
          left_indent: 1440,
          hanging_indent: 720
        )
        expect(level.level).to eq(2)
        expect(level.format).to eq('upperRoman')
        expect(level.start).to eq(5)
        expect(level.alignment).to eq('right')
        expect(level.left_indent).to eq(1440)
        expect(level.hanging_indent).to eq(720)
      end

      it 'raises error for invalid format' do
        expect do
          Uniword::Wordprocessingml::NumberingLevel.new(format: 'invalid')
        end.to raise_error(ArgumentError, /Invalid format/)
      end

      it 'raises error for invalid alignment' do
        expect do
          Uniword::Wordprocessingml::NumberingLevel.new(alignment: 'invalid')
        end.to raise_error(ArgumentError, /Invalid alignment/)
      end
    end

    describe '#bullet!' do
      it 'sets level as bullet' do
        level = Uniword::Wordprocessingml::NumberingLevel.new
        level.bullet!("\u2022")
        expect(level.bullet?).to be true
        expect(level.format).to eq('bullet')
        expect(level.text).to eq("\u2022")
        expect(level.font_name).to eq('Symbol')
      end

      it 'allows custom font' do
        level = Uniword::Wordprocessingml::NumberingLevel.new
        level.bullet!("\u25A0", font_name: 'Wingdings')
        expect(level.font_name).to eq('Wingdings')
      end
    end

    describe '#numbering_text' do
      it 'returns bullet character for bullet format' do
        level = Uniword::Wordprocessingml::NumberingLevel.new(format: 'bullet', text: '•')
        expect(level.numbering_text).to eq('•')
      end

      it 'returns default decimal text' do
        level = Uniword::Wordprocessingml::NumberingLevel.new(level: 0, format: 'decimal')
        expect(level.numbering_text).to eq('%1.')
      end

      it 'returns custom text if provided' do
        level = Uniword::Wordprocessingml::NumberingLevel.new(level: 0, format: 'decimal', text: '%1)')
        expect(level.numbering_text).to eq('%1)')
      end
    end
  end

  describe Uniword::Wordprocessingml::NumberingDefinition do
    describe '#initialize' do
      it 'creates empty definition' do
        defn = Uniword::Wordprocessingml::NumberingDefinition.new(abstract_num_id: 0)
        expect(defn.abstract_num_id).to eq(0)
        expect(defn.levels).to be_empty
      end
    end

    describe '#add_level' do
      it 'adds a level to the definition' do
        defn = Uniword::Wordprocessingml::NumberingDefinition.new(abstract_num_id: 0)
        level = defn.add_level(format: 'decimal', start: 1)
        expect(defn.levels.size).to eq(1)
        expect(level.level).to eq(0)
      end

      it 'auto-assigns level index' do
        defn = Uniword::Wordprocessingml::NumberingDefinition.new(abstract_num_id: 0)
        defn.add_level(format: 'decimal')
        defn.add_level(format: 'lowerLetter')
        expect(defn.levels[0].level).to eq(0)
        expect(defn.levels[1].level).to eq(1)
      end

      it 'raises error when exceeding max levels' do
        defn = Uniword::Wordprocessingml::NumberingDefinition.new(abstract_num_id: 0)
        9.times { defn.add_level(format: 'decimal') }
        expect do
          defn.add_level(format: 'decimal')
        end.to raise_error(ArgumentError, /Cannot add more than 9 levels/)
      end
    end

    describe '#level' do
      it 'retrieves level by index' do
        defn = Uniword::Wordprocessingml::NumberingDefinition.new(abstract_num_id: 0)
        level1 = defn.add_level(format: 'decimal')
        level2 = defn.add_level(format: 'upperRoman')
        expect(defn.level(0)).to eq(level1)
        expect(defn.level(1)).to eq(level2)
      end
    end

    describe '.decimal' do
      it 'creates decimal numbering definition' do
        defn = Uniword::Wordprocessingml::NumberingDefinition.decimal(abstract_num_id: 1)
        expect(defn.abstract_num_id).to eq(1)
        expect(defn.name).to eq('Decimal')
        expect(defn.levels.size).to eq(9)
        defn.levels.each do |level|
          expect(level.format).to eq('decimal')
          expect(level.start).to eq(1)
        end
      end
    end

    describe '.bullet' do
      it 'creates bullet numbering definition' do
        defn = Uniword::Wordprocessingml::NumberingDefinition.bullet(abstract_num_id: 2)
        expect(defn.abstract_num_id).to eq(2)
        expect(defn.name).to eq('Bullet')
        expect(defn.levels.size).to eq(9)
        expect(defn.levels[0].format).to eq('bullet')
        expect(defn.levels[0].text).to eq("\u2022")
        expect(defn.levels[1].text).to eq("\u25CB")
        expect(defn.levels[2].text).to eq("\u25A0")
      end
    end

    describe '.roman' do
      it 'creates upper roman numbering' do
        defn = Uniword::Wordprocessingml::NumberingDefinition.roman(abstract_num_id: 3, upper: true)
        expect(defn.levels[0].format).to eq('upperRoman')
      end

      it 'creates lower roman numbering' do
        defn = Uniword::Wordprocessingml::NumberingDefinition.roman(abstract_num_id: 4, upper: false)
        expect(defn.levels[0].format).to eq('lowerRoman')
      end
    end

    describe '.letter' do
      it 'creates upper letter numbering' do
        defn = Uniword::Wordprocessingml::NumberingDefinition.letter(abstract_num_id: 5, upper: true)
        expect(defn.levels[0].format).to eq('upperLetter')
      end

      it 'creates lower letter numbering' do
        defn = Uniword::Wordprocessingml::NumberingDefinition.letter(abstract_num_id: 6, upper: false)
        expect(defn.levels[0].format).to eq('lowerLetter')
      end
    end
  end

  describe Uniword::Wordprocessingml::NumberingInstance do
    describe '#initialize' do
      it 'creates instance with valid IDs' do
        instance = Uniword::Wordprocessingml::NumberingInstance.new(num_id: 1, abstract_num_id: 0)
        expect(instance.num_id).to eq(1)
        expect(instance.abstract_num_id).to eq(0)
      end

      it 'raises error for invalid num_id' do
        expect do
          Uniword::Wordprocessingml::NumberingInstance.new(num_id: 0, abstract_num_id: 0)
        end.to raise_error(ArgumentError, /num_id must be >= 1/)
      end

      it 'raises error for invalid abstract_num_id' do
        expect do
          Uniword::Wordprocessingml::NumberingInstance.new(num_id: 1, abstract_num_id: -1)
        end.to raise_error(ArgumentError, /abstract_num_id must be >= 0/)
      end
    end

    describe '#uses_definition?' do
      it 'returns true for matching definition' do
        instance = Uniword::Wordprocessingml::NumberingInstance.new(num_id: 1, abstract_num_id: 5)
        definition = Uniword::Wordprocessingml::NumberingDefinition.new(abstract_num_id: 5)
        expect(instance.uses_definition?(definition)).to be true
      end

      it 'returns false for non-matching definition' do
        instance = Uniword::Wordprocessingml::NumberingInstance.new(num_id: 1, abstract_num_id: 5)
        definition = Uniword::Wordprocessingml::NumberingDefinition.new(abstract_num_id: 3)
        expect(instance.uses_definition?(definition)).to be false
      end
    end
  end

  describe Uniword::Wordprocessingml::NumberingConfiguration do
    describe '#initialize' do
      it 'creates empty configuration' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        expect(config.definitions).to be_empty
        expect(config.instances).to be_empty
        expect(config.has_numbering?).to be false
      end
    end

    describe '#add_definition' do
      it 'adds definition with auto-assigned ID' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        defn = config.add_definition(name: 'Test')
        expect(defn.abstract_num_id).to eq(0)
        expect(config.definitions).to include(defn)
      end

      it 'respects provided abstract_num_id' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        defn = Uniword::Wordprocessingml::NumberingDefinition.new(abstract_num_id: 5)
        config.add_definition(defn)
        expect(defn.abstract_num_id).to eq(5)
      end
    end

    describe '#add_instance' do
      it 'adds instance with auto-assigned num_id' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        instance = config.add_instance(abstract_num_id: 0)
        expect(instance.num_id).to eq(1)
        expect(config.instances).to include(instance)
      end

      it 'respects provided num_id' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        instance = config.add_instance(abstract_num_id: 0, num_id: 10)
        expect(instance.num_id).to eq(10)
      end
    end

    describe '#create_numbering' do
      it 'creates decimal numbering' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        num_id = config.create_numbering(:decimal)
        expect(num_id).to eq(1)
        expect(config.definitions.size).to eq(1)
        expect(config.instances.size).to eq(1)
        expect(config.definitions.first.levels.first.format).to eq('decimal')
      end

      it 'creates bullet numbering' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        config.create_numbering(:bullet)
        expect(config.definitions.first.levels.first.format).to eq('bullet')
      end

      it 'creates roman numbering' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        config.create_numbering(:roman, upper: true)
        expect(config.definitions.first.levels.first.format).to eq('upperRoman')
      end

      it 'creates letter numbering' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        config.create_numbering(:letter, upper: false)
        expect(config.definitions.first.levels.first.format).to eq('lowerLetter')
      end

      it 'raises error for unknown type' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        expect do
          config.create_numbering(:invalid)
        end.to raise_error(ArgumentError, /Unknown numbering type/)
      end
    end

    describe '#get_definition' do
      it 'retrieves definition by ID' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        defn = config.add_definition(name: 'Test')
        expect(config.get_definition(defn.abstract_num_id)).to eq(defn)
      end
    end

    describe '#get_instance' do
      it 'retrieves instance by ID' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        instance = config.add_instance(abstract_num_id: 0)
        expect(config.get_instance(instance.num_id)).to eq(instance)
      end
    end

    describe '#get_definition_for_num_id' do
      it 'retrieves definition via instance' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        num_id = config.create_numbering(:decimal)
        definition = config.get_definition_for_num_id(num_id)
        expect(definition).not_to be_nil
        expect(definition.levels.first.format).to eq('decimal')
      end
    end

    describe '#default_decimal_num_id' do
      it 'creates default decimal numbering' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        num_id1 = config.default_decimal_num_id
        num_id2 = config.default_decimal_num_id
        expect(num_id1).to eq(num_id2) # Should return same ID
      end
    end

    describe '#default_bullet_num_id' do
      it 'creates default bullet numbering' do
        config = Uniword::Wordprocessingml::NumberingConfiguration.new
        num_id1 = config.default_bullet_num_id
        num_id2 = config.default_bullet_num_id
        expect(num_id1).to eq(num_id2) # Should return same ID
      end
    end
  end

  describe 'Paragraph Integration' do
    describe '#set_numbering' do
      it 'sets numbering on paragraph' do
        para = Uniword::Paragraph.new
        para.set_numbering(1, 0)
        expect(para.num_id).to eq(1)
        expect(para.ilvl).to eq(0)
      end

      it 'preserves other properties' do
        props = Uniword::Wordprocessingml::ParagraphProperties.new(
          style: 'Normal',
          alignment: 'left'
        )
        para = Uniword::Paragraph.new(properties: props)
        para.set_numbering(2, 1)
        expect(para.num_id).to eq(2)
        expect(para.ilvl).to eq(1)
        expect(para.style).to eq('Normal')
        expect(para.alignment).to eq('left')
      end
    end

    describe '#numbered?' do
      it 'returns true for numbered paragraph' do
        para = Uniword::Paragraph.new
        para.set_numbering(1, 0)
        expect(para.numbered?).to be true
      end

      it 'returns false for non-numbered paragraph' do
        para = Uniword::Paragraph.new
        expect(para.numbered?).to be false
      end
    end
  end

  describe 'Document Integration' do
    it 'initializes with numbering configuration' do
      doc = Uniword::Document.new
      expect(doc.numbering_configuration).to be_a(Uniword::Wordprocessingml::NumberingConfiguration)
    end

    it 'creates numbered list in document' do
      doc = Uniword::Document.new
      num_id = doc.numbering_configuration.create_numbering(:decimal)

      para1 = Uniword::Paragraph.new
      para1.add_text('First item')
      para1.set_numbering(num_id, 0)

      para2 = Uniword::Paragraph.new
      para2.add_text('Second item')
      para2.set_numbering(num_id, 0)

      doc.body.add_paragraph(para1)
      doc.body.add_paragraph(para2)

      expect(para1.numbered?).to be true
      expect(para2.numbered?).to be true
      expect(para1.num_id).to eq(para2.num_id)
    end
  end
end
