# frozen_string_literal: true

require 'spec_helper'
require 'uniword/mhtml/css_number_formatter'

RSpec.describe Uniword::Mhtml::CssNumberFormatter do
  describe '.format' do
    it 'formats integer values with unit' do
      expect(described_class.format(12, 'pt')).to eq('12pt')
    end

    it 'formats decimal values with appropriate precision' do
      expect(described_class.format(12.5, 'pt')).to eq('12.5pt')
      expect(described_class.format(12.25, 'pt')).to eq('12.25pt')
    end

    it 'removes trailing zeros' do
      expect(described_class.format(12.00, 'pt')).to eq('12pt')
      expect(described_class.format(12.50, 'pt')).to eq('12.5pt')
    end

    it 'rounds to specified precision' do
      expect(described_class.format(12.345, 'pt', precision: 2)).to eq('12.35pt')
      expect(described_class.format(12.345, 'pt', precision: 1)).to eq('12.3pt')
      expect(described_class.format(12.345, 'pt', precision: 0)).to eq('12pt')
    end

    it 'omits unit for zero values with common units' do
      expect(described_class.format(0, 'px')).to eq('0')
      expect(described_class.format(0, 'pt')).to eq('0')
      expect(described_class.format(0, 'em')).to eq('0')
      expect(described_class.format(0, '%')).to eq('0')
      expect(described_class.format(0, 'in')).to eq('0')
    end

    it 'handles nil values' do
      expect(described_class.format(nil, 'pt')).to be_nil
    end

    it 'supports various CSS units' do
      expect(described_class.format(16, 'px')).to eq('16px')
      expect(described_class.format(1.5, 'em')).to eq('1.5em')
      expect(described_class.format(50, '%')).to eq('50%')
      expect(described_class.format(1, 'in')).to eq('1in')
      expect(described_class.format(10, 'cm')).to eq('10cm')
    end

    it 'handles very small decimals' do
      expect(described_class.format(0.5, 'pt')).to eq('0.5pt')
      expect(described_class.format(0.25, 'em')).to eq('0.25em')
    end
  end

  describe '.twips_to_pt' do
    it 'converts twips to points' do
      # 1 pt = 20 twips
      expect(described_class.twips_to_pt(20)).to eq('1pt')
      expect(described_class.twips_to_pt(40)).to eq('2pt')
      expect(described_class.twips_to_pt(240)).to eq('12pt')
    end

    it 'handles decimal conversions' do
      expect(described_class.twips_to_pt(30)).to eq('1.5pt')
      expect(described_class.twips_to_pt(25)).to eq('1.25pt')
    end

    it 'removes trailing zeros' do
      expect(described_class.twips_to_pt(40)).to eq('2pt')
    end

    it 'handles nil values' do
      expect(described_class.twips_to_pt(nil)).to be_nil
    end

    it 'handles zero values' do
      expect(described_class.twips_to_pt(0)).to eq('0')
    end
  end

  describe '.twips_to_in' do
    it 'converts twips to inches' do
      # 1 inch = 1440 twips
      expect(described_class.twips_to_in(1440)).to eq('1in')
      expect(described_class.twips_to_in(2880)).to eq('2in')
    end

    it 'handles decimal conversions' do
      expect(described_class.twips_to_in(720)).to eq('0.5in')
      expect(described_class.twips_to_in(1080)).to eq('0.75in')
    end

    it 'formats with appropriate precision' do
      # Default precision is 2
      expect(described_class.twips_to_in(1440)).to eq('1in')
      expect(described_class.twips_to_in(1440, precision: 1)).to eq('1in')
    end

    it 'handles nil values' do
      expect(described_class.twips_to_in(nil)).to be_nil
    end

    it 'handles zero values' do
      expect(described_class.twips_to_in(0)).to eq('0')
    end
  end

  describe '.format_font_size' do
    it 'converts half-points to points' do
      # Font sizes are typically in half-points
      expect(described_class.format_font_size(24)).to eq('12pt')
      expect(described_class.format_font_size(32)).to eq('16pt')
      expect(described_class.format_font_size(22)).to eq('11pt')
    end

    it 'handles decimal half-point values' do
      expect(described_class.format_font_size(25)).to eq('12.5pt')
    end

    it 'uses precision of 1 by default' do
      expect(described_class.format_font_size(24.5)).to eq('12.3pt')
    end

    it 'handles nil values' do
      expect(described_class.format_font_size(nil)).to be_nil
    end

    it 'handles zero values' do
      expect(described_class.format_font_size(0)).to eq('0')
    end
  end

  describe '.format_percentage' do
    it 'formats percentage values' do
      expect(described_class.format_percentage(50)).to eq('50%')
      expect(described_class.format_percentage(100)).to eq('100%')
    end

    it 'uses precision of 0 by default' do
      expect(described_class.format_percentage(50.5)).to eq('51%')
      expect(described_class.format_percentage(75.2)).to eq('75%')
    end

    it 'supports custom precision' do
      expect(described_class.format_percentage(50.5, precision: 1)).to eq('50.5%')
      expect(described_class.format_percentage(75.25, precision: 2)).to eq('75.25%')
    end

    it 'handles nil values' do
      expect(described_class.format_percentage(nil)).to be_nil
    end

    it 'handles zero values' do
      expect(described_class.format_percentage(0)).to eq('0')
    end
  end

  describe 'edge cases' do
    it 'handles very large numbers' do
      expect(described_class.format(9999, 'pt')).to eq('9999pt')
      expect(described_class.format(10000.5, 'px')).to eq('10000.5px')
    end

    it 'handles negative numbers' do
      expect(described_class.format(-12, 'pt')).to eq('-12pt')
      expect(described_class.format(-12.5, 'em')).to eq('-12.5em')
    end

    it 'handles precision edge cases' do
      # Very high precision
      expect(described_class.format(1.23456789, 'pt', precision: 5)).to eq('1.23457pt')

      # Zero precision
      expect(described_class.format(12.9, 'pt', precision: 0)).to eq('13pt')
    end
  end
end