# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Wordprocessingml::Style do
  describe 'basic style creation' do
    it 'creates a style with required attributes' do
      style = described_class.new(
        styleId: 'TestStyle',
        name: Uniword::Wordprocessingml::StyleName.new(val: 'Test Style'),
        type: 'paragraph'
      )

      expect(style.id).to eq('TestStyle')
      expect(style.style_name).to eq('Test Style')
      expect(style.type).to eq('paragraph')
    end

    it 'creates a style with properties' do
      style = described_class.new(
        styleId: 'CustomStyle',
        name: Uniword::Wordprocessingml::StyleName.new(val: 'Custom Style'),
        type: 'paragraph',
        customStyle: true,
        basedOn: Uniword::Wordprocessingml::BasedOn.new(val: 'Normal')
      )

      expect(style.custom?).to be true
      expect(style.based_on).to eq('Normal')
    end
  end

  describe '#paragraph_style?' do
    it 'returns true for paragraph styles' do
      style = described_class.new(styleId: 'P1',
                                  name: Uniword::Wordprocessingml::StyleName.new(val: 'P1'), type: 'paragraph')
      expect(style.paragraph_style?).to be true
      expect(style.character_style?).to be false
    end
  end

  describe '#character_style?' do
    it 'returns true for character styles' do
      style = described_class.new(styleId: 'C1',
                                  name: Uniword::Wordprocessingml::StyleName.new(val: 'C1'), type: 'character')
      expect(style.character_style?).to be true
      expect(style.paragraph_style?).to be false
    end
  end
end

RSpec.describe Uniword::Wordprocessingml::StylesConfiguration do
  describe 'initialization' do
    it 'creates empty configuration' do
      config = described_class.new(include_defaults: false)
      expect(config.styles).to eq([])
    end

    it 'creates configuration with styles' do
      style = Uniword::Wordprocessingml::Style.new(styleId: 'Test',
                                                   name: Uniword::Wordprocessingml::StyleName.new(val: 'Test'), type: 'paragraph')
      config = described_class.new(styles: [style])
      expect(config.styles.size).to eq(1)
    end
  end

  describe '#add_style' do
    let(:config) { described_class.new(include_defaults: false) }

    it 'adds a style' do
      style = Uniword::Wordprocessingml::Style.new(styleId: 'Custom',
                                                   name: Uniword::Wordprocessingml::StyleName.new(val: 'Custom'), type: 'paragraph')
      config.add_style(style)
      expect(config.styles.size).to eq(1)
      expect(config.style_by_id('Custom')).not_to be_nil
    end

    it 'raises error for duplicate style IDs' do
      style1 = Uniword::Wordprocessingml::Style.new(styleId: 'Custom',
                                                    name: Uniword::Wordprocessingml::StyleName.new(val: 'Custom'), type: 'paragraph')
      style2 = Uniword::Wordprocessingml::Style.new(styleId: 'Custom',
                                                    name: Uniword::Wordprocessingml::StyleName.new(val: 'Custom 2'), type: 'paragraph')

      config.add_style(style1)
      expect do
        config.add_style(style2)
      end.to raise_error(ArgumentError, /already exists/)
    end

    it 'allows overwriting with allow_overwrite flag' do
      style1 = Uniword::Wordprocessingml::Style.new(styleId: 'Custom',
                                                    name: Uniword::Wordprocessingml::StyleName.new(val: 'Custom'), type: 'paragraph')
      style2 = Uniword::Wordprocessingml::Style.new(styleId: 'Custom',
                                                    name: Uniword::Wordprocessingml::StyleName.new(val: 'Custom 2'), type: 'paragraph')

      config.add_style(style1)
      config.add_style(style2, allow_overwrite: true)
      expect(config.style_by_id('Custom').style_name).to eq('Custom 2')
    end
  end

  describe '#remove_style' do
    let(:config) { described_class.new(include_defaults: false) }
    let(:style) { Uniword::Wordprocessingml::Style.new(styleId: 'Custom', name: Uniword::Wordprocessingml::StyleName.new(val: 'Custom'), type: 'paragraph') }

    before { config.add_style(style) }

    it 'removes a style' do
      removed = config.remove_style('Custom')
      expect(removed).to eq(style)
      expect(config.styles).to be_empty
    end
  end

  describe '#style_by_id' do
    let(:config) { described_class.new }
    let(:style) { Uniword::Wordprocessingml::Style.new(styleId: 'TestID', name: Uniword::Wordprocessingml::StyleName.new(val: 'Test Name'), type: 'paragraph') }

    before { config.add_style(style) }

    it 'finds style by ID' do
      found = config.style_by_id('TestID')
      expect(found).to eq(style)
    end

    it 'returns nil for unknown ID' do
      expect(config.style_by_id('Unknown')).to be_nil
    end
  end

  describe '#style_by_name' do
    let(:config) { described_class.new }
    let(:style) { Uniword::Wordprocessingml::Style.new(styleId: 'TestID', name: Uniword::Wordprocessingml::StyleName.new(val: 'Test Name'), type: 'paragraph') }

    before { config.add_style(style) }

    it 'finds style by name' do
      found = config.style_by_name('Test Name')
      expect(found).to eq(style)
    end

    it 'returns nil for unknown name' do
      expect(config.style_by_name('Unknown')).to be_nil
    end
  end

  describe 'style filtering' do
    let(:config) { described_class.new(include_defaults: false) }
    let(:para_style) { Uniword::Wordprocessingml::Style.new(styleId: 'Para', name: Uniword::Wordprocessingml::StyleName.new(val: 'Para'), type: 'paragraph') }
    let(:char_style) { Uniword::Wordprocessingml::Style.new(styleId: 'Char', name: Uniword::Wordprocessingml::StyleName.new(val: 'Char'), type: 'character') }

    before do
      config.add_style(para_style)
      config.add_style(char_style)
    end

    it 'filters paragraph styles' do
      para_styles = config.paragraph_styles
      expect(para_styles).to include(para_style)
      expect(para_styles.size).to eq(1)
    end

    it 'filters character styles' do
      char_styles = config.character_styles
      expect(char_styles).to include(char_style)
      expect(char_styles.size).to eq(1)
    end
  end
end
