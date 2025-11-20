# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::TableBorder do
  describe '#initialize' do
    it 'creates border with default values' do
      border = Uniword::TableBorder.new
      expect(border.style).to eq('single')
      expect(border.width).to eq(4)
      expect(border.color).to eq('auto')
      expect(border.space).to eq(0)
    end

    it 'creates border with custom values' do
      border = Uniword::TableBorder.new(
        style: 'double',
        width: 8,
        color: 'FF0000',
        space: 2
      )
      expect(border.style).to eq('double')
      expect(border.width).to eq(8)
      expect(border.color).to eq('FF0000')
      expect(border.space).to eq(2)
    end

    it 'raises error for invalid style' do
      expect {
        Uniword::TableBorder.new(style: 'invalid')
      }.to raise_error(ArgumentError, /Invalid border style/)
    end
  end

  describe '.single' do
    it 'creates single border with defaults' do
      border = Uniword::TableBorder.single
      expect(border.style).to eq('single')
      expect(border.width).to eq(4)
      expect(border.color).to eq('auto')
    end

    it 'accepts custom width and color' do
      border = Uniword::TableBorder.single(width: 6, color: '0000FF')
      expect(border.width).to eq(6)
      expect(border.color).to eq('0000FF')
    end
  end

  describe '.double' do
    it 'creates double border' do
      border = Uniword::TableBorder.double
      expect(border.style).to eq('double')
      expect(border.width).to eq(6)
    end
  end

  describe '.dashed' do
    it 'creates dashed border' do
      border = Uniword::TableBorder.dashed
      expect(border.style).to eq('dashed')
    end
  end

  describe '.dotted' do
    it 'creates dotted border' do
      border = Uniword::TableBorder.dotted
      expect(border.style).to eq('dotted')
    end
  end

  describe '.thick' do
    it 'creates thick border' do
      border = Uniword::TableBorder.thick
      expect(border.style).to eq('thick')
      expect(border.width).to eq(8)
    end
  end

  describe '.none' do
    it 'creates no border' do
      border = Uniword::TableBorder.none
      expect(border.style).to eq('none')
      expect(border.width).to eq(0)
    end
  end
end

RSpec.describe 'Table Properties with Borders' do
  it 'creates table properties with individual borders' do
    props = Uniword::Properties::TableProperties.new(
      top_border: Uniword::TableBorder.single,
      bottom_border: Uniword::TableBorder.double,
      left_border: Uniword::TableBorder.dashed,
      right_border: Uniword::TableBorder.dotted,
      inside_h_border: Uniword::TableBorder.thick,
      inside_v_border: Uniword::TableBorder.single(color: 'FF0000')
    )

    expect(props.top_border.style).to eq('single')
    expect(props.bottom_border.style).to eq('double')
    expect(props.left_border.style).to eq('dashed')
    expect(props.right_border.style).to eq('dotted')
    expect(props.inside_h_border.style).to eq('thick')
    expect(props.inside_v_border.color).to eq('FF0000')
  end

  it 'creates table properties with cell spacing and padding' do
    props = Uniword::Properties::TableProperties.new(
      cell_spacing: 100,
      cell_padding: 80
    )

    expect(props.cell_spacing).to eq(100)
    expect(props.cell_padding).to eq(80)
  end

  it 'equality works with border properties' do
    border1 = Uniword::TableBorder.single
    border2 = Uniword::TableBorder.single

    props1 = Uniword::Properties::TableProperties.new(top_border: border1)
    props2 = Uniword::Properties::TableProperties.new(top_border: border2)

    expect(props1).to eq(props2)
  end
end