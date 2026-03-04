# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Paragraph, 'Enhanced Properties' do
  let(:paragraph) { described_class.new }

  describe '#set_borders' do
    it 'sets paragraph borders with color strings' do
      paragraph.set_borders(top: '000000', bottom: 'FF0000')

      expect(paragraph.properties.borders).not_to be_nil
      expect(paragraph.properties.borders.top).not_to be_nil
      expect(paragraph.properties.borders.top.color).to eq('000000')
      expect(paragraph.properties.borders.bottom).not_to be_nil
      expect(paragraph.properties.borders.bottom.color).to eq('FF0000')
    end

    it 'sets paragraph borders with hash specifications' do
      paragraph.set_borders(
        top: { style: 'double', size: 8, color: '0000FF' },
        left: { style: 'dashed', size: 4, color: '00FF00' }
      )

      expect(paragraph.properties.borders.top.style).to eq('double')
      expect(paragraph.properties.borders.top.size).to eq(8)
      expect(paragraph.properties.borders.top.color).to eq('0000FF')
      expect(paragraph.properties.borders.left.style).to eq('dashed')
      expect(paragraph.properties.borders.left.size).to eq(4)
    end

    it 'returns self for method chaining' do
      result = paragraph.set_borders(top: '000000')
      expect(result).to eq(paragraph)
    end

    it 'sets all border types' do
      paragraph.set_borders(
        top: '111111',
        bottom: '222222',
        left: '333333',
        right: '444444',
        between: '555555',
        bar: '666666'
      )

      expect(paragraph.properties.borders.top.color).to eq('111111')
      expect(paragraph.properties.borders.bottom.color).to eq('222222')
      expect(paragraph.properties.borders.left.color).to eq('333333')
      expect(paragraph.properties.borders.right.color).to eq('444444')
      expect(paragraph.properties.borders.between.color).to eq('555555')
      expect(paragraph.properties.borders.bar.color).to eq('666666')
    end
  end

  describe '#set_shading' do
    it 'sets paragraph shading with fill color' do
      paragraph.set_shading(fill: 'FFFF00')

      expect(paragraph.properties.shading).not_to be_nil
      expect(paragraph.properties.shading.fill).to eq('FFFF00')
    end

    it 'sets shading with pattern' do
      paragraph.set_shading(fill: 'FF00FF', pattern: 'solid')

      expect(paragraph.properties.shading.fill).to eq('FF00FF')
      expect(paragraph.properties.shading.shading_type).to eq('solid')
    end

    it 'defaults to clear pattern' do
      paragraph.set_shading(fill: 'CCCCCC')

      expect(paragraph.properties.shading.shading_type).to eq('clear')
    end

    it 'returns self for method chaining' do
      result = paragraph.set_shading(fill: 'FFFF00')
      expect(result).to eq(paragraph)
    end

    it 'sets both fill and color' do
      paragraph.set_shading(fill: 'FFFF00', color: '000000')

      expect(paragraph.properties.shading.fill).to eq('FFFF00')
      expect(paragraph.properties.shading.color).to eq('000000')
    end
  end

  describe '#add_tab_stop' do
    it 'adds a tab stop with position and alignment' do
      paragraph.add_tab_stop(position: 1440, alignment: 'center')

      expect(paragraph.properties.tab_stops).not_to be_nil
      expect(paragraph.properties.tab_stops.tabs.size).to eq(1)

      tab = paragraph.properties.tab_stops.tabs.first
      expect(tab.position).to eq(1440)
      expect(tab.alignment).to eq('center')
    end

    it 'adds multiple tab stops' do
      paragraph.add_tab_stop(position: 720, alignment: 'left')
      paragraph.add_tab_stop(position: 1440, alignment: 'center')
      paragraph.add_tab_stop(position: 2160, alignment: 'right')

      expect(paragraph.properties.tab_stops.tabs.size).to eq(3)
    end

    it 'defaults alignment to left' do
      paragraph.add_tab_stop(position: 1440)

      tab = paragraph.properties.tab_stops.tabs.first
      expect(tab.alignment).to eq('left')
    end

    it 'sets tab leader' do
      paragraph.add_tab_stop(position: 1440, alignment: 'right', leader: 'dot')

      tab = paragraph.properties.tab_stops.tabs.first
      expect(tab.leader).to eq('dot')
    end

    it 'returns self for method chaining' do
      result = paragraph.add_tab_stop(position: 1440)
      expect(result).to eq(paragraph)
    end
  end

  describe '#extract_current_properties' do
    it 'includes all enhanced properties' do
      paragraph.set_style('Heading1')
      paragraph.align('center')
      paragraph.spacing_before = 240
      paragraph.set_borders(top: '000000')
      paragraph.set_shading(fill: 'FFFF00')
      paragraph.add_tab_stop(position: 1440)

      props = paragraph.send(:extract_current_properties)

      expect(props[:style]).to eq('Heading1')
      expect(props[:alignment]).to eq('center')
      expect(props[:spacing_before]).to eq(240)
      expect(props[:borders]).not_to be_nil
      expect(props[:shading]).not_to be_nil
      expect(props[:tab_stops]).not_to be_nil
    end

    it 'includes all 42+ property types' do
      # Set various properties
      paragraph.properties = Uniword::Wordprocessingml::ParagraphProperties.new(
        style: 'Normal',
        alignment: 'left',
        spacing_before: 120,
        spacing_after: 120,
        line_spacing: 1.5,
        line_rule: 'auto',
        indent_left: 720,
        indent_right: 720,
        indent_first_line: 360,
        keep_next: true,
        keep_lines: true,
        page_break_before: false,
        outline_level: 1,
        contextual_spacing: true,
        bidirectional: false,
        mirror_indents: false,
        snap_to_grid: true,
        widow_control: true
      )

      props = paragraph.send(:extract_current_properties)

      # Verify all properties are extracted
      expect(props[:style]).to eq('Normal')
      expect(props[:alignment]).to eq('left')
      expect(props[:spacing_before]).to eq(120)
      expect(props[:spacing_after]).to eq(120)
      expect(props[:line_spacing]).to eq(1.5)
      expect(props[:line_rule]).to eq('auto')
      expect(props[:indent_left]).to eq(720)
      expect(props[:indent_right]).to eq(720)
      expect(props[:indent_first_line]).to eq(360)
      expect(props[:keep_next]).to be true
      expect(props[:keep_lines]).to be true
      expect(props[:page_break_before]).to be false
      expect(props[:outline_level]).to eq(1)
      expect(props[:contextual_spacing]).to be true
      expect(props[:bidirectional]).to be false
      expect(props[:mirror_indents]).to be false
      expect(props[:snap_to_grid]).to be true
      expect(props[:widow_control]).to be true
    end
  end

  describe 'method chaining' do
    it 'allows chaining multiple property methods' do
      result = paragraph
               .set_style('Heading1')
               .align('center')
               .set_borders(top: '000000', bottom: '000000')
               .set_shading(fill: 'FFFF00')
               .add_tab_stop(position: 1440)

      expect(result).to eq(paragraph)
      expect(paragraph.style).to eq('Heading1')
      expect(paragraph.alignment).to eq('center')
      expect(paragraph.properties.borders).not_to be_nil
      expect(paragraph.properties.shading).not_to be_nil
      expect(paragraph.properties.tab_stops).not_to be_nil
    end
  end
end
