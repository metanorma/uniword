# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Wordprocessingml::ParagraphProperties do
  describe '#initialize' do
    it 'creates properties with default values' do
      props = described_class.new
      expect(props.style).to be_nil
      expect(props.alignment).to be_nil
      expect(props.keep_next).to be false
    end

    it 'creates properties with provided attributes' do
      props = described_class.new(
        style: 'Heading1',
        alignment: 'center',
        spacing_before: 240,
        spacing_after: 120
      )
      expect(props.style.value).to eq('Heading1')
      expect(props.alignment.value).to eq('center')
      expect(props.spacing&.before).to eq(240)
      expect(props.spacing&.after).to eq(120)
    end

    it 'allows mutation for test compatibility' do
      props = described_class.new(style: 'Normal')
      expect(props).not_to be_frozen
    end
  end

  describe 'mutability (for test compatibility)' do
    let(:props) { described_class.new(style: 'Normal', alignment: 'left') }

    it 'allows modification of attributes' do
      props.style = 'Changed'
      expect(props.style).to eq('Changed')
    end

    it 'is not frozen' do
      expect(props.frozen?).to be false
    end
  end

  describe '#==' do
    it 'returns true for identical properties' do
      props1 = described_class.new(style: 'Normal', alignment: 'left')
      props2 = described_class.new(style: 'Normal', alignment: 'left')
      expect(props1).to eq(props2)
    end

    it 'returns false for different properties' do
      props1 = described_class.new(style: 'Normal')
      props2 = described_class.new(style: 'Heading1')
      expect(props1).not_to eq(props2)
    end

    it 'returns false for different types' do
      props = described_class.new(style: 'Normal')
      expect(props).not_to eq('Normal')
    end

    it 'compares all attributes' do
      props1 = described_class.new(
        style: 'Normal',
        alignment: 'left',
        spacing_before: 120,
        spacing_after: 120,
        indent_left: 720
      )
      props2 = described_class.new(
        style: 'Normal',
        alignment: 'left',
        spacing_before: 120,
        spacing_after: 120,
        indent_left: 720
      )
      expect(props1).to eq(props2)
    end
  end

  describe '#eql?' do
    it 'is an alias for ==' do
      props1 = described_class.new(style: 'Normal')
      props2 = described_class.new(style: 'Normal')
      expect(props1.eql?(props2)).to eq(props1 == props2)
    end
  end

  describe '#hash' do
    it 'returns same hash for equal objects' do
      props1 = described_class.new(style: 'Normal', alignment: 'left')
      props2 = described_class.new(style: 'Normal', alignment: 'left')
      expect(props1.hash).to eq(props2.hash)
    end

    it 'returns different hash for different objects' do
      props1 = described_class.new(style: 'Normal')
      props2 = described_class.new(style: 'Heading1')
      expect(props1.hash).not_to eq(props2.hash)
    end

    it 'allows use as hash keys' do
      props1 = described_class.new(style: 'Normal')
      props2 = described_class.new(style: 'Normal')
      hash = { props1 => 'value1' }
      expect(hash[props2]).to eq('value1')
    end
  end

  describe 'boolean attributes' do
    it 'defaults boolean attributes to false' do
      props = described_class.new
      expect(props.keep_next).to be false
      expect(props.keep_lines).to be false
      expect(props.page_break_before).to be false
    end

    it 'allows setting boolean attributes' do
      props = described_class.new(
        keep_next_wrapper: Uniword::Properties::KeepNext.new(value: true),
        keep_lines_wrapper: Uniword::Properties::KeepLines.new(value: true),
        page_break_before: true
      )
      expect(props.keep_next).to be true
      expect(props.keep_lines).to be true
      expect(props.page_break_before).to be true
    end
  end

  describe 'inheritance' do
    it 'inherits from Lutaml::Model::Serializable' do
      expect(described_class.ancestors)
        .to include(Lutaml::Model::Serializable)
    end
  end
end
