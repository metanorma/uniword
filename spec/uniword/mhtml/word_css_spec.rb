# frozen_string_literal: true

require 'spec_helper'
require 'uniword/mhtml/word_css'

RSpec.describe Uniword::Mhtml::WordCss do
  describe '.default_css' do
    it 'returns CSS string' do
      css = described_class.default_css
      expect(css).to be_a(String)
      expect(css).not_to be_empty
    end

    it 'includes MsoNormal style' do
      css = described_class.default_css
      expect(css).to include('MsoNormal')
    end

    it 'includes heading styles' do
      css = described_class.default_css
      expect(css).to include('h1')
      expect(css).to include('h2')
      expect(css).to include('h3')
    end

    it 'includes font definitions' do
      css = described_class.default_css
      expect(css).to include('@font-face')
      expect(css).to include('font-family')
    end

    it 'includes page definitions' do
      css = described_class.default_css
      expect(css).to include('@page')
    end

    it 'includes list definitions' do
      css = described_class.default_css
      expect(css).to include('@list')
    end

    it 'includes table styles' do
      css = described_class.default_css
      expect(css).to include('MsoNormalTable')
    end
  end

  describe '.basic_css' do
    it 'returns fallback CSS' do
      css = described_class.basic_css
      expect(css).to be_a(String)
      expect(css).not_to be_empty
    end

    it 'includes essential styles' do
      css = described_class.basic_css
      expect(css).to include('MsoNormal')
      expect(css).to include('h1')
      expect(css).to include('h2')
      expect(css).to include('h3')
      expect(css).to include('MsoNormalTable')
      expect(css).to include('MsoHyperlink')
    end
  end

  describe '.generate_style_css' do
    it 'returns empty string for nil config' do
      css = described_class.generate_style_css(nil)
      expect(css).to eq('')
    end

    it 'generates CSS for styles' do
      # Create a mock style
      style = double('Style',
                     style_id: 'CustomStyle',
                     font: 'Arial',
                     font_size: 12,
                     bold: true,
                     italic: false,
                     alignment: 'center')

      config = double('StylesConfiguration')
      allow(config).to receive(:styles).and_return([style])

      css = described_class.generate_style_css(config)
      expect(css).to include('.CustomStyle')
      expect(css).to include('Arial')
      expect(css).to include('12pt')
      expect(css).to include('bold')
      expect(css).to include('center')
    end

    it 'handles styles without optional properties' do
      style = double('Style', style_id: 'Simple')
      allow(style).to receive(:respond_to?).and_return(false)

      config = double('StylesConfiguration')
      allow(config).to receive(:styles).and_return([style])

      css = described_class.generate_style_css(config)
      # Should not raise error, may return empty or minimal CSS
      expect(css).to be_a(String)
    end
  end

  describe '.generate_list_css' do
    it 'returns empty string for nil config' do
      css = described_class.generate_list_css(nil)
      expect(css).to eq('')
    end

    it 'generates CSS for numbering' do
      instance = double('NumberingInstance', num_id: 1)

      config = double('NumberingConfiguration')
      allow(config).to receive(:instances).and_return([instance])

      css = described_class.generate_list_css(config)
      expect(css).to include('@list l1')
      expect(css).to include('mso-list-id: 1')
    end

    it 'handles multiple numbering instances' do
      instances = [
        double('NumberingInstance', num_id: 1),
        double('NumberingInstance', num_id: 2),
        double('NumberingInstance', num_id: 3)
      ]

      config = double('NumberingConfiguration')
      allow(config).to receive(:instances).and_return(instances)

      css = described_class.generate_list_css(config)
      expect(css).to include('@list l1')
      expect(css).to include('@list l2')
      expect(css).to include('@list l3')
    end
  end

  describe '.build_style_rule' do
    it 'returns nil for nil style' do
      rule = described_class.build_style_rule(nil)
      expect(rule).to be_nil
    end

    it 'builds CSS rule for style with font' do
      style = double('Style', style_id: 'TestStyle', font: 'Times New Roman')
      allow(style).to receive(:respond_to?).with(:font).and_return(true)
      allow(style).to receive(:respond_to?).with(:font_size).and_return(false)
      allow(style).to receive(:respond_to?).with(:bold).and_return(false)
      allow(style).to receive(:respond_to?).with(:italic).and_return(false)
      allow(style).to receive(:respond_to?).with(:alignment).and_return(false)

      rule = described_class.build_style_rule(style)
      expect(rule).to include('.TestStyle')
      expect(rule).to include('Times New Roman')
    end

    it 'builds CSS rule for style with multiple properties' do
      style = double('Style',
                     style_id: 'RichStyle',
                     font: 'Arial',
                     font_size: 14,
                     bold: true,
                     italic: true,
                     alignment: 'right')
      allow(style).to receive(:respond_to?).with(:font).and_return(true)
      allow(style).to receive(:respond_to?).with(:font_size).and_return(true)
      allow(style).to receive(:respond_to?).with(:bold).and_return(true)
      allow(style).to receive(:respond_to?).with(:italic).and_return(true)
      allow(style).to receive(:respond_to?).with(:alignment).and_return(true)

      rule = described_class.build_style_rule(style)
      expect(rule).to include('.RichStyle')
      expect(rule).to include('Arial')
      expect(rule).to include('14pt')
      expect(rule).to include('bold')
      expect(rule).to include('italic')
      expect(rule).to include('right')
    end

    it 'returns nil for style with no properties' do
      style = double('Style', style_id: 'EmptyStyle')
      allow(style).to receive(:respond_to?).and_return(false)

      rule = described_class.build_style_rule(style)
      expect(rule).to be_nil
    end
  end

  describe '.build_list_rule' do
    it 'returns nil for nil instance' do
      rule = described_class.build_list_rule(nil)
      expect(rule).to be_nil
    end

    it 'builds @list rule' do
      instance = double('NumberingInstance', num_id: 5)

      rule = described_class.build_list_rule(instance)
      expect(rule).to include('@list l5')
      expect(rule).to include('mso-list-id: 5')
    end
  end

  describe 'CSS file existence' do
    it 'wordstyle.css file exists' do
      css_path = File.join(__dir__, '../../../lib/uniword/mhtml/wordstyle.css')
      expect(File.exist?(css_path)).to be true
    end

    it 'wordstyle.css is readable' do
      css_path = File.join(__dir__, '../../../lib/uniword/mhtml/wordstyle.css')
      expect(File.readable?(css_path)).to be true
    end

    it 'wordstyle.css is not empty' do
      css_path = File.join(__dir__, '../../../lib/uniword/mhtml/wordstyle.css')
      content = File.read(css_path)
      expect(content.length).to be > 100
    end
  end
end
