# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Wordprocessingml::TableProperties do
  describe '#initialize' do
    it 'creates properties with default values' do
      props = described_class.new
      expect(props.style).to be_nil
      expect(props.borders).to be false
      expect(props.allow_break).to be true
    end

    it 'creates properties with provided attributes' do
      props = described_class.new(
        style: 'TableGrid',
        table_width: Uniword::Properties::TableWidth.new(w: 100),
        alignment: 'center',
        borders: true
      )
      expect(props.style).to eq('TableGrid')
      expect(props.table_width.w).to eq(100)
      expect(props.alignment).to eq('center')
      expect(props.borders).to be true
    end

    it 'allows mutation for test compatibility' do
      props = described_class.new(style: 'TableGrid')
      # Properties are now mutable for easier testing
      expect(props).not_to be_frozen
    end
  end

  describe 'mutability (for test compatibility)' do
    let(:props) { described_class.new(style: 'TableGrid', width: 100) }

    it 'allows modification of attributes' do
      # Properties are now mutable for easier testing
      expect { props.style = 'Changed' }.not_to raise_error
      expect(props.style).to eq('Changed')
    end

    it 'is not frozen' do
      expect(props.frozen?).to be false
    end
  end

  describe '#==' do
    it 'returns true for identical properties' do
      props1 = described_class.new(style: 'TableGrid', width: 100)
      props2 = described_class.new(style: 'TableGrid', width: 100)
      expect(props1).to eq(props2)
    end

    it 'returns false for different properties' do
      props1 = described_class.new(style: 'TableGrid')
      props2 = described_class.new(style: 'TableNormal')
      expect(props1).not_to eq(props2)
    end

    it 'returns false for different types' do
      props = described_class.new(style: 'TableGrid')
      expect(props).not_to eq('TableGrid')
    end

    it 'compares all attributes' do
      props1 = described_class.new(
        style: 'TableGrid',
        width: 100,
        alignment: 'center',
        borders: true,
        cell_spacing: 0
      )
      props2 = described_class.new(
        style: 'TableGrid',
        width: 100,
        alignment: 'center',
        borders: true,
        cell_spacing: 0
      )
      expect(props1).to eq(props2)
    end
  end

  describe '#eql?' do
    it 'is an alias for ==' do
      props1 = described_class.new(style: 'TableGrid')
      props2 = described_class.new(style: 'TableGrid')
      expect(props1.eql?(props2)).to eq(props1 == props2)
    end
  end

  describe '#hash' do
    it 'returns same hash for equal objects' do
      props1 = described_class.new(style: 'TableGrid', width: 100)
      props2 = described_class.new(style: 'TableGrid', width: 100)
      expect(props1.hash).to eq(props2.hash)
    end

    it 'returns different hash for different objects' do
      props1 = described_class.new(style: 'TableGrid')
      props2 = described_class.new(style: 'TableNormal')
      expect(props1.hash).not_to eq(props2.hash)
    end

    it 'allows use as hash keys' do
      props1 = described_class.new(style: 'TableGrid')
      props2 = described_class.new(style: 'TableGrid')
      hash = { props1 => 'value1' }
      expect(hash[props2]).to eq('value1')
    end
  end

  describe 'boolean attributes' do
    it 'defaults borders to false' do
      props = described_class.new
      expect(props.borders).to be false
    end

    it 'defaults allow_break to true' do
      props = described_class.new
      expect(props.allow_break).to be true
    end

    it 'allows setting boolean attributes' do
      props = described_class.new(
        borders: true,
        allow_break: false
      )
      expect(props.borders).to be true
      expect(props.allow_break).to be false
    end
  end

  describe 'inheritance' do
    it 'inherits from Lutaml::Model::Serializable' do
      expect(described_class.ancestors)
        .to include(Lutaml::Model::Serializable)
    end
  end
end
