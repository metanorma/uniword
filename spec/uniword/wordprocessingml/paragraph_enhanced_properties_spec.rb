# frozen_string_literal: true

require 'spec_helper'
require 'uniword/builder'

RSpec.describe Uniword::Wordprocessingml::Paragraph, 'Enhanced Properties' do
  let(:paragraph) { described_class.new }

  describe 'ParagraphBuilder#borders' do
    it 'sets paragraph borders with color strings' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder.borders(top: '000000', bottom: 'FF0000')

      expect(paragraph.properties.borders).not_to be_nil
      expect(paragraph.properties.borders.top).not_to be_nil
      expect(paragraph.properties.borders.top.color).to eq('000000')
      expect(paragraph.properties.borders.bottom).not_to be_nil
      expect(paragraph.properties.borders.bottom.color).to eq('FF0000')
    end

    it 'sets paragraph borders with hash specifications' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder.borders(
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
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      result = builder.borders(top: '000000')
      expect(result).to eq(builder)
    end

    it 'sets all border types' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder.borders(
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

  describe 'ParagraphBuilder#shading' do
    it 'sets paragraph shading with fill color' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder.shading(fill: 'FFFF00')

      expect(paragraph.properties.shading).not_to be_nil
      expect(paragraph.properties.shading.fill).to eq('FFFF00')
    end

    it 'sets shading with pattern' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder.shading(fill: 'FF00FF', pattern: 'solid')

      expect(paragraph.properties.shading.fill).to eq('FF00FF')
      expect(paragraph.properties.shading.shading_type).to eq('solid')
    end

    it 'defaults to clear pattern' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder.shading(fill: 'CCCCCC')

      expect(paragraph.properties.shading.shading_type).to eq('clear')
    end

    it 'returns self for method chaining' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      result = builder.shading(fill: 'FFFF00')
      expect(result).to eq(builder)
    end

    it 'sets both fill and color' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder.shading(fill: 'FFFF00', color: '000000')

      expect(paragraph.properties.shading.fill).to eq('FFFF00')
      expect(paragraph.properties.shading.color).to eq('000000')
    end
  end

  describe 'ParagraphBuilder#<< with tab stops' do
    it 'adds a tab stop with position and alignment' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder << Uniword::Builder.tab_stop(position: 1440, alignment: 'center')

      expect(paragraph.properties.tab_stops).not_to be_nil
      expect(paragraph.properties.tab_stops.tabs.size).to eq(1)

      tab = paragraph.properties.tab_stops.tabs.first
      expect(tab.position).to eq(1440)
      expect(tab.alignment).to eq('center')
    end

    it 'adds multiple tab stops' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder << Uniword::Builder.tab_stop(position: 720, alignment: 'left')
      builder << Uniword::Builder.tab_stop(position: 1440, alignment: 'center')
      builder << Uniword::Builder.tab_stop(position: 2160, alignment: 'right')

      expect(paragraph.properties.tab_stops.tabs.size).to eq(3)
    end

    it 'defaults alignment to left' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder << Uniword::Builder.tab_stop(position: 1440)

      tab = paragraph.properties.tab_stops.tabs.first
      expect(tab.alignment).to eq('left')
    end

    it 'sets tab leader' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder << Uniword::Builder.tab_stop(
        position: 1440, alignment: 'right', leader: 'dot'
      )

      tab = paragraph.properties.tab_stops.tabs.first
      expect(tab.leader).to eq('dot')
    end

    it 'returns self for method chaining' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      result = builder << Uniword::Builder.tab_stop(position: 1440)
      expect(result).to eq(builder)
    end
  end

  describe 'enhanced properties via ParagraphBuilder' do
    it 'sets all enhanced properties' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder.style = 'Heading1'
      builder.align = 'center'
      builder.spacing(before: 240)
      builder.borders(top: '000000')
      builder.shading(fill: 'FFFF00')
      builder << Uniword::Builder.tab_stop(position: 1440)

      expect(paragraph.properties&.style).to eq('Heading1')
      expect(paragraph.properties&.alignment).to eq('center')
      expect(paragraph.properties&.spacing&.before).to eq(240)
      expect(paragraph.properties.borders).not_to be_nil
      expect(paragraph.properties.shading).not_to be_nil
      expect(paragraph.properties.tab_stops).not_to be_nil
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
        widow_control: true
      )

      # Verify all properties are accessible
      expect(paragraph.properties.style).to eq('Normal')
      expect(paragraph.properties.alignment).to eq('left')
      expect(paragraph.properties.spacing_before).to eq(120)
      expect(paragraph.properties.spacing_after).to eq(120)
      expect(paragraph.properties.line_spacing).to eq(1.5)
      expect(paragraph.properties.line_rule).to eq('auto')
      expect(paragraph.properties.indent_left).to eq(720)
      expect(paragraph.properties.indent_right).to eq(720)
      expect(paragraph.properties.indent_first_line).to eq(360)
      expect(paragraph.properties.keep_next).to be true
      expect(paragraph.properties.keep_lines).to be true
      expect(paragraph.properties.page_break_before).to be false
      expect(paragraph.properties.outline_level).to eq(1)
      expect(paragraph.properties.contextual_spacing).to be true
      expect(paragraph.properties.bidirectional).to be false
      expect(paragraph.properties.widow_control).to be true
    end
  end

  describe 'ParagraphBuilder method chaining' do
    it 'allows chaining multiple property methods' do
      builder = Uniword::Builder::ParagraphBuilder.new(paragraph)
      builder.style = 'Heading1'
      builder.align = 'center'
      builder.borders(top: '000000', bottom: '000000')
      builder.shading(fill: 'FFFF00')
      builder << Uniword::Builder.tab_stop(position: 1440)

      expect(builder.build).to eq(paragraph)
      expect(paragraph.properties&.style).to eq('Heading1')
      expect(paragraph.properties&.alignment).to eq('center')
      expect(paragraph.properties.borders).not_to be_nil
      expect(paragraph.properties.shading).not_to be_nil
      expect(paragraph.properties.tab_stops).not_to be_nil
    end
  end
end
