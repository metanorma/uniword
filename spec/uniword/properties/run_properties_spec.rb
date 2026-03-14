# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Wordprocessingml::RunProperties do
  describe '#initialize' do
    it 'creates properties with default values' do
      props = described_class.new
      expect(props.bold).to be_nil
      expect(props.italic).to be_nil
      expect(props.strike).to be_nil
      expect(props.small_caps).to be_nil
      expect(props.caps).to be_nil
      expect(props.hidden).to be_nil
    end

    it 'creates properties with provided attributes' do
      props = described_class.new(
        bold: Uniword::Properties::Bold.new(value: true),
        italic: Uniword::Properties::Italic.new(value: true),
        size: Uniword::Properties::FontSize.new(value: 24),
        color: Uniword::Properties::ColorValue.new(value: '000000')
      )
      # Set fonts after initialization (lutaml-model creates fresh instances for nested objects)
      props.fonts = Uniword::Properties::RunFonts.new(ascii: 'Arial')

      expect(props.bold?).to be true
      expect(props.italic?).to be true
      expect(props.size&.value).to eq(24)
      expect(props.fonts.ascii).to eq('Arial')
      expect(props.color&.value).to eq('000000')
    end

    it 'allows mutation for test compatibility' do
      props = described_class.new(bold: Uniword::Properties::Bold.new(value: true))
      # Properties are now mutable for easier testing
      expect(props).not_to be_frozen
    end
  end

  describe 'mutability (for test compatibility)' do
    let(:props) do
      described_class.new(
        bold: Uniword::Properties::Bold.new(value: true),
        fonts: Uniword::Properties::RunFonts.new(ascii: 'Arial')
      )
    end

    it 'allows modification of attributes' do
      # Properties are now mutable for easier testing
      expect { props.bold = Uniword::Properties::Bold.new(value: false) }.not_to raise_error
      expect(props.bold?).to be false
    end

    it 'is not frozen' do
      expect(props.frozen?).to be false
    end
  end

  describe '#==' do
    it 'returns true for identical properties' do
      props1 = described_class.new(
        bold: Uniword::Properties::Bold.new(value: true),
        italic: Uniword::Properties::Italic.new(value: false),
        size: Uniword::Properties::FontSize.new(value: 24)
      )
      props2 = described_class.new(
        bold: Uniword::Properties::Bold.new(value: true),
        italic: Uniword::Properties::Italic.new(value: false),
        size: Uniword::Properties::FontSize.new(value: 24)
      )
      expect(props1).to eq(props2)
    end

    it 'returns false for different properties' do
      props1 = described_class.new(bold: Uniword::Properties::Bold.new(value: true))
      props2 = described_class.new(bold: Uniword::Properties::Bold.new(value: false))
      expect(props1).not_to eq(props2)
    end

    it 'returns false for different types' do
      props = described_class.new(bold: Uniword::Properties::Bold.new(value: true))
      expect(props).not_to eq(true)
    end

    it 'compares all attributes' do
      props1 = described_class.new(
        bold: Uniword::Properties::Bold.new(value: true),
        italic: Uniword::Properties::Italic.new(value: false),
        underline: Uniword::Properties::Underline.new(value: 'single'),
        size: Uniword::Properties::FontSize.new(value: 24),
        fonts: Uniword::Properties::RunFonts.new(ascii: 'Arial'),
        color: Uniword::Properties::ColorValue.new(value: '000000')
      )
      props2 = described_class.new(
        bold: Uniword::Properties::Bold.new(value: true),
        italic: Uniword::Properties::Italic.new(value: false),
        underline: Uniword::Properties::Underline.new(value: 'single'),
        size: Uniword::Properties::FontSize.new(value: 24),
        fonts: Uniword::Properties::RunFonts.new(ascii: 'Arial'),
        color: Uniword::Properties::ColorValue.new(value: '000000')
      )
      expect(props1).to eq(props2)
    end
  end

  describe '#eql?' do
    it 'is an alias for ==' do
      props1 = described_class.new(bold: Uniword::Properties::Bold.new(value: true))
      props2 = described_class.new(bold: Uniword::Properties::Bold.new(value: true))
      expect(props1.eql?(props2)).to eq(props1 == props2)
    end
  end

  describe '#hash' do
    it 'returns same hash for equal objects' do
      props1 = described_class.new(
        bold: Uniword::Properties::Bold.new(value: true),
        size: Uniword::Properties::FontSize.new(value: 24)
      )
      props2 = described_class.new(
        bold: Uniword::Properties::Bold.new(value: true),
        size: Uniword::Properties::FontSize.new(value: 24)
      )
      expect(props1.hash).to eq(props2.hash)
    end

    it 'returns different hash for different objects' do
      props1 = described_class.new(bold: Uniword::Properties::Bold.new(value: true))
      props2 = described_class.new(bold: Uniword::Properties::Bold.new(value: false))
      expect(props1.hash).not_to eq(props2.hash)
    end

    it 'allows use as hash keys' do
      props1 = described_class.new(bold: Uniword::Properties::Bold.new(value: true))
      props2 = described_class.new(bold: Uniword::Properties::Bold.new(value: true))
      hash = { props1 => 'value1' }
      expect(hash[props2]).to eq('value1')
    end
  end

  describe 'boolean attributes' do
    it 'defaults boolean attributes to nil (wrapper objects)' do
      props = described_class.new
      expect(props.bold).to be_nil
      expect(props.italic).to be_nil
      expect(props.strike).to be_nil
      expect(props.small_caps).to be_nil
      expect(props.caps).to be_nil
      expect(props.hidden).to be_nil
    end

    it 'allows setting boolean wrapper objects' do
      props = described_class.new(
        bold: Uniword::Properties::Bold.new(value: true),
        italic: Uniword::Properties::Italic.new(value: true),
        strike: Uniword::Properties::Strike.new(value: true),
        small_caps: Uniword::Properties::SmallCaps.new(value: true),
        caps: Uniword::Properties::Caps.new(value: true),
        hidden: Uniword::Properties::Vanish.new(value: true)
      )
      expect(props.bold?).to be true
      expect(props.italic?).to be true
      expect(props.strike?).to be true
      expect(props.small_caps?).to be true
      expect(props.caps?).to be true
      expect(props.hidden?).to be true
    end

    it 'provides predicate methods for boolean properties' do
      props = described_class.new(
        bold: Uniword::Properties::Bold.new(value: true),
        italic: Uniword::Properties::Italic.new(value: false)
      )
      expect(props.bold?).to be true
      expect(props.italic?).to be false
      expect(props.strike?).to be false # nil returns false
    end
  end

  describe 'inheritance' do
    it 'inherits from Lutaml::Model::Serializable' do
      expect(described_class.ancestors)
        .to include(Lutaml::Model::Serializable)
    end
  end
end
