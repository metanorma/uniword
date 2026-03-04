# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Wordprocessingml::RunProperties do
  describe '#initialize' do
    it 'creates properties with default values' do
      props = described_class.new
      expect(props.bold).to be false
      expect(props.italic).to be false
      expect(props.strike).to be false
      expect(props.small_caps).to be false
      expect(props.caps).to be false
      expect(props.hidden).to be false
    end

    it 'creates properties with provided attributes' do
      props = described_class.new(
        bold: true,
        italic: true,
        size: 24,
        font: 'Arial',
        color: '000000'
      )
      expect(props.bold).to be true
      expect(props.italic).to be true
      expect(props.size).to eq(24)
      expect(props.font).to eq('Arial')
      expect(props.color).to eq('000000')
    end

    it 'allows mutation for test compatibility' do
      props = described_class.new(bold: true)
      # Properties are now mutable for easier testing
      expect(props).not_to be_frozen
    end
  end

  describe 'mutability (for test compatibility)' do
    let(:props) { described_class.new(bold: true, font: 'Arial') }

    it 'allows modification of attributes' do
      # Properties are now mutable for easier testing
      expect { props.bold = false }.not_to raise_error
      expect(props.bold).to be false
    end

    it 'is not frozen' do
      expect(props.frozen?).to be false
    end
  end

  describe '#==' do
    it 'returns true for identical properties' do
      props1 = described_class.new(bold: true, italic: false, size: 24)
      props2 = described_class.new(bold: true, italic: false, size: 24)
      expect(props1).to eq(props2)
    end

    it 'returns false for different properties' do
      props1 = described_class.new(bold: true)
      props2 = described_class.new(bold: false)
      expect(props1).not_to eq(props2)
    end

    it 'returns false for different types' do
      props = described_class.new(bold: true)
      expect(props).not_to eq(true)
    end

    it 'compares all attributes' do
      props1 = described_class.new(
        bold: true,
        italic: false,
        underline: 'single',
        size: 24,
        font: 'Arial',
        color: '000000'
      )
      props2 = described_class.new(
        bold: true,
        italic: false,
        underline: 'single',
        size: 24,
        font: 'Arial',
        color: '000000'
      )
      expect(props1).to eq(props2)
    end
  end

  describe '#eql?' do
    it 'is an alias for ==' do
      props1 = described_class.new(bold: true)
      props2 = described_class.new(bold: true)
      expect(props1.eql?(props2)).to eq(props1 == props2)
    end
  end

  describe '#hash' do
    it 'returns same hash for equal objects' do
      props1 = described_class.new(bold: true, size: 24)
      props2 = described_class.new(bold: true, size: 24)
      expect(props1.hash).to eq(props2.hash)
    end

    it 'returns different hash for different objects' do
      props1 = described_class.new(bold: true)
      props2 = described_class.new(bold: false)
      expect(props1.hash).not_to eq(props2.hash)
    end

    it 'allows use as hash keys' do
      props1 = described_class.new(bold: true)
      props2 = described_class.new(bold: true)
      hash = { props1 => 'value1' }
      expect(hash[props2]).to eq('value1')
    end
  end

  describe 'boolean attributes' do
    it 'defaults boolean attributes to false' do
      props = described_class.new
      expect(props.bold).to be false
      expect(props.italic).to be false
      expect(props.strike).to be false
      expect(props.small_caps).to be false
      expect(props.caps).to be false
      expect(props.hidden).to be false
    end

    it 'allows setting boolean attributes' do
      props = described_class.new(
        bold: true,
        italic: true,
        strike: true,
        small_caps: true,
        caps: true,
        hidden: true
      )
      expect(props.bold).to be true
      expect(props.italic).to be true
      expect(props.strike).to be true
      expect(props.small_caps).to be true
      expect(props.caps).to be true
      expect(props.hidden).to be true
    end
  end

  describe 'inheritance' do
    it 'inherits from Lutaml::Model::Serializable' do
      expect(described_class.ancestors)
        .to include(Lutaml::Model::Serializable)
    end
  end
end
