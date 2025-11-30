# frozen_string_literal: true

require 'spec_helper'
require 'uniword/style'
require 'uniword/paragraph_style'
require 'uniword/character_style'
require 'uniword/styles_configuration'

RSpec.describe Uniword::Style do
  describe 'basic style creation' do
    it 'creates a style with required attributes' do
      style = described_class.new(
        id: 'TestStyle',
        name: 'Test Style',
        type: 'paragraph'
      )

      expect(style.id).to eq('TestStyle')
      expect(style.name).to eq('Test Style')
      expect(style.type).to eq('paragraph')
    end

    it 'validates style type' do
      valid_style = described_class.new(
        id: 'Test',
        name: 'Test',
        type: 'paragraph'
      )

      invalid_style = described_class.new(
        id: 'Test',
        name: 'Test',
        type: 'invalid'
      )

      expect(valid_style.valid?).to be true
      expect(invalid_style.valid?).to be false
    end
  end

  describe 'style inheritance' do
    it 'supports basedOn property' do
      described_class.new(
        id: 'Base',
        name: 'Base',
        type: 'paragraph'
      )

      derived_style = described_class.new(
        id: 'Derived',
        name: 'Derived',
        type: 'paragraph',
        based_on: 'Base'
      )

      expect(derived_style.based_on).to eq('Base')
    end
  end

  describe 'style type checks' do
    it 'identifies paragraph styles' do
      style = described_class.new(
        id: 'Test',
        name: 'Test',
        type: 'paragraph'
      )

      expect(style.paragraph_style?).to be true
      expect(style.character_style?).to be false
      expect(style.table_style?).to be false
      expect(style.numbering_style?).to be false
    end

    it 'identifies character styles' do
      style = described_class.new(
        id: 'Test',
        name: 'Test',
        type: 'character'
      )

      expect(style.character_style?).to be true
      expect(style.paragraph_style?).to be false
    end
  end
end

RSpec.describe Uniword::ParagraphStyle do
  describe 'Normal style creation' do
    it 'creates default Normal style' do
      style = described_class.normal

      expect(style.id).to eq('Normal')
      expect(style.name).to eq('Normal')
      expect(style.type).to eq('paragraph')
      expect(style.default).to be true
    end

    it 'Normal style has default formatting' do
      style = described_class.normal

      expect(style.paragraph_properties).not_to be_nil
      expect(style.run_properties).not_to be_nil
      expect(style.run_properties.font).to eq('Calibri')
    end
  end

  describe 'Heading styles' do
    it 'creates heading styles for levels 1-9' do
      (1..9).each do |level|
        style = described_class.heading(level)

        expect(style.id).to eq("Heading#{level}")
        expect(style.name).to eq("Heading #{level}") # Name has space per OOXML spec
        expect(style.type).to eq('paragraph')
        expect(style.based_on).to eq('Normal')
      end
    end

    it 'Heading 1 has larger font than Heading 2' do
      h1 = described_class.heading(1)
      h2 = described_class.heading(2)

      expect(h1.run_properties.size).to be > h2.run_properties.size
    end

    it 'Lower heading levels are bold' do
      h1 = described_class.heading(1)
      h2 = described_class.heading(2)
      h3 = described_class.heading(3)
      h4 = described_class.heading(4)

      expect(h1.run_properties.bold).to be true
      expect(h2.run_properties.bold).to be true
      expect(h3.run_properties.bold).to be true
      expect(h4.run_properties.bold).to be false
    end

    it 'raises error for invalid heading level' do
      expect { described_class.heading(0) }.to raise_error(ArgumentError)
      expect { described_class.heading(10) }.to raise_error(ArgumentError)
    end
  end

  describe 'custom paragraph style' do
    it 'creates custom style with properties' do
      style = described_class.new(
        id: 'CustomPara',
        name: 'Custom Paragraph',
        type: 'paragraph',
        custom: true,
        paragraph_properties: Uniword::Properties::ParagraphProperties.new(
          alignment: 'center'
        ),
        run_properties: Uniword::Properties::RunProperties.new(
          bold: true,
          size: 28
        )
      )

      expect(style.custom).to be true
      expect(style.paragraph_properties.alignment).to eq('center')
      expect(style.run_properties.bold).to be true
    end
  end
end

RSpec.describe Uniword::CharacterStyle do
  describe 'default character style' do
    it 'creates default character style' do
      style = described_class.default_char

      expect(style.id).to eq('DefaultParagraphFont')
      expect(style.type).to eq('character')
      expect(style.default).to be true
    end
  end

  describe 'built-in character styles' do
    it 'creates Emphasis style' do
      style = described_class.emphasis

      expect(style.id).to eq('Emphasis')
      expect(style.run_properties.italic).to be true
    end

    it 'creates Strong style' do
      style = described_class.strong

      expect(style.id).to eq('Strong')
      expect(style.run_properties.bold).to be true
    end
  end

  describe 'custom character style' do
    it 'creates custom style with formatting' do
      style = described_class.new(
        id: 'CustomChar',
        name: 'Custom Character',
        type: 'character',
        custom: true,
        run_properties: Uniword::Properties::RunProperties.new(
          color: 'FF0000',
          underline: 'single'
        )
      )

      expect(style.custom).to be true
      expect(style.run_properties.color).to eq('FF0000')
      expect(style.run_properties.underline).to eq('single')
    end
  end
end

RSpec.describe Uniword::StylesConfiguration do
  describe 'initialization' do
    it 'creates empty configuration without defaults' do
      config = described_class.new({}, include_defaults: false)

      expect(config.styles).to be_empty
    end

    it 'creates configuration with default styles' do
      config = described_class.new

      expect(config.styles).not_to be_empty
      expect(config.style_by_id('Normal')).not_to be_nil
      expect(config.style_by_id('Heading1')).not_to be_nil
    end

    it 'includes all default heading styles' do
      config = described_class.new

      (1..9).each do |level|
        expect(config.style_by_id("Heading#{level}")).not_to be_nil
      end
    end

    it 'includes default character styles' do
      config = described_class.new

      expect(config.style_by_id('DefaultParagraphFont')).not_to be_nil
      expect(config.style_by_id('Emphasis')).not_to be_nil
      expect(config.style_by_id('Strong')).not_to be_nil
    end
  end

  describe 'style management' do
    let(:config) { described_class.new({}, include_defaults: false) }

    it 'adds a style' do
      style = Uniword::ParagraphStyle.new(
        id: 'Custom',
        name: 'Custom',
        type: 'paragraph'
      )

      config.add_style(style)

      expect(config.styles.size).to eq(1)
      expect(config.style_by_id('Custom')).to eq(style)
    end

    it 'prevents duplicate style IDs' do
      style1 = Uniword::ParagraphStyle.new(
        id: 'Custom',
        name: 'Custom',
        type: 'paragraph'
      )
      style2 = Uniword::ParagraphStyle.new(
        id: 'Custom',
        name: 'Custom 2',
        type: 'paragraph'
      )

      config.add_style(style1)

      expect do
        config.add_style(style2)
      end.to raise_error(ArgumentError, /already exists/)
    end

    it 'removes a style' do
      style = Uniword::ParagraphStyle.new(
        id: 'Custom',
        name: 'Custom',
        type: 'paragraph'
      )

      config.add_style(style)
      removed = config.remove_style('Custom')

      expect(removed).to eq(style)
      expect(config.styles).to be_empty
    end

    it 'finds style by name' do
      style = Uniword::ParagraphStyle.new(
        id: 'CustomID',
        name: 'Custom Name',
        type: 'paragraph'
      )

      config.add_style(style)

      expect(config.style_by_name('Custom Name')).to eq(style)
    end

    it 'finds style by ID or name' do
      style = Uniword::ParagraphStyle.new(
        id: 'CustomID',
        name: 'Custom Name',
        type: 'paragraph'
      )

      config.add_style(style)

      expect(config.style('CustomID')).to eq(style)
      expect(config.style('Custom Name')).to eq(style)
    end
  end

  describe 'style filtering' do
    let(:config) { described_class.new }

    it 'filters paragraph styles' do
      para_styles = config.paragraph_styles

      expect(para_styles).to all(be_a(Uniword::Style))
      expect(para_styles.map(&:type).uniq).to eq(['paragraph'])
    end

    it 'filters character styles' do
      char_styles = config.character_styles

      expect(char_styles).to all(be_a(Uniword::Style))
      expect(char_styles.map(&:type).uniq).to eq(['character'])
    end

    it 'filters default styles' do
      default_styles = config.default_styles

      expect(default_styles).to all(have_attributes(default: true))
    end

    it 'filters custom styles' do
      custom_style = Uniword::ParagraphStyle.new(
        id: 'Custom',
        name: 'Custom',
        type: 'paragraph',
        custom: true
      )

      config.add_style(custom_style)
      custom_styles = config.custom_styles

      expect(custom_styles).to include(custom_style)
      expect(custom_styles).to all(have_attributes(custom: true))
    end
  end

  describe 'style creation helpers' do
    let(:config) { described_class.new({}, include_defaults: false) }

    it 'creates custom paragraph style' do
      style = config.create_paragraph_style(
        'MyStyle',
        'My Style',
        paragraph_properties: Uniword::Properties::ParagraphProperties.new(
          alignment: 'right'
        )
      )

      expect(style).to be_a(Uniword::ParagraphStyle)
      expect(style.id).to eq('MyStyle')
      expect(style.custom).to be true
      expect(config.style_by_id('MyStyle')).to eq(style)
    end

    it 'creates custom character style' do
      style = config.create_character_style(
        'MyCharStyle',
        'My Character Style',
        run_properties: Uniword::Properties::RunProperties.new(
          color: '0000FF'
        )
      )

      expect(style).to be_a(Uniword::CharacterStyle)
      expect(style.id).to eq('MyCharStyle')
      expect(style.custom).to be true
      expect(config.style_by_id('MyCharStyle')).to eq(style)
    end
  end

  describe 'validation' do
    let(:config) { described_class.new({}, include_defaults: false) }

    it 'validates all styles' do
      valid_style = Uniword::ParagraphStyle.new(
        id: 'Valid',
        name: 'Valid',
        type: 'paragraph'
      )

      config.add_style(valid_style)

      expect(config.valid?).to be true
    end
  end

  describe 'style inheritance resolution' do
    let(:config) { described_class.new({}, include_defaults: false) }

    it 'resolves simple inheritance' do
      base = Uniword::ParagraphStyle.new(
        id: 'Base',
        name: 'Base',
        type: 'paragraph',
        paragraph_properties: Uniword::Properties::ParagraphProperties.new(
          alignment: 'left'
        )
      )

      derived = Uniword::ParagraphStyle.new(
        id: 'Derived',
        name: 'Derived',
        type: 'paragraph',
        based_on: 'Base',
        paragraph_properties: Uniword::Properties::ParagraphProperties.new(
          spacing_before: 100
        )
      )

      config.add_style(base)
      config.add_style(derived)

      props = config.resolve_inheritance('Derived')

      expect(props[:paragraph_properties]).not_to be_nil
    end
  end
end
