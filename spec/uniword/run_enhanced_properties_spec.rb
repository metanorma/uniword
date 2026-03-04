# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Run, 'Enhanced Properties' do
  let(:run) { described_class.new(text: 'Test text') }

  describe '#character_spacing' do
    it 'sets and gets character spacing' do
      run.character_spacing = 20
      expect(run.character_spacing).to eq(20)
    end

    it 'returns nil when not set' do
      expect(run.character_spacing).to be_nil
    end
  end

  describe '#kerning' do
    it 'sets and gets kerning threshold' do
      run.kerning = 24
      expect(run.kerning).to eq(24)
    end

    it 'returns nil when not set' do
      expect(run.kerning).to be_nil
    end
  end

  describe '#set_shading' do
    it 'sets text shading with fill color' do
      run.set_shading(fill: 'FFFF00')

      expect(run.shading).not_to be_nil
      expect(run.shading.fill).to eq('FFFF00')
    end

    it 'sets shading with pattern' do
      run.set_shading(fill: 'FF00FF', pattern: 'solid')

      expect(run.shading.fill).to eq('FF00FF')
      expect(run.shading.shading_type).to eq('solid')
    end

    it 'defaults to clear pattern' do
      run.set_shading(fill: 'CCCCCC')
      expect(run.shading.shading_type).to eq('clear')
    end

    it 'returns self for method chaining' do
      result = run.set_shading(fill: 'FFFF00')
      expect(result).to eq(run)
    end
  end

  describe '#position' do
    it 'sets and gets raised position' do
      run.position = 10
      expect(run.position).to eq(10)
    end

    it 'sets and gets lowered position' do
      run.position = -10
      expect(run.position).to eq(-10)
    end

    it 'returns nil when not set' do
      expect(run.position).to be_nil
    end
  end

  describe '#text_expansion' do
    it 'sets and gets text expansion' do
      run.text_expansion = 120
      expect(run.text_expansion).to eq(120)
    end

    it 'sets compression' do
      run.text_expansion = 80
      expect(run.text_expansion).to eq(80)
    end

    it 'returns nil when not set' do
      expect(run.text_expansion).to be_nil
    end
  end

  describe 'text effects' do
    describe '#outline' do
      it 'sets and gets outline effect' do
        run.outline = true
        expect(run.outline).to be true
      end

      it 'defaults to false' do
        expect(run.outline).to be false
      end
    end

    describe '#shadow' do
      it 'sets and gets shadow effect' do
        run.shadow = true
        expect(run.shadow).to be true
      end

      it 'defaults to false' do
        expect(run.shadow).to be false
      end
    end

    describe '#emboss' do
      it 'sets and gets emboss effect' do
        run.emboss = true
        expect(run.emboss).to be true
      end

      it 'defaults to false' do
        expect(run.emboss).to be false
      end
    end

    describe '#imprint' do
      it 'sets and gets imprint effect' do
        run.imprint = true
        expect(run.imprint).to be true
      end

      it 'defaults to false' do
        expect(run.imprint).to be false
      end
    end
  end

  describe '#hidden' do
    it 'sets and gets hidden text' do
      run.hidden = true
      expect(run.hidden).to be true
    end

    it 'defaults to false' do
      expect(run.hidden).to be false
    end
  end

  describe '#emphasis_mark' do
    it 'sets and gets emphasis mark' do
      run.emphasis_mark = 'dot'
      expect(run.emphasis_mark).to eq('dot')
    end

    it 'supports different mark types' do
      %w[dot comma circle underDot].each do |mark|
        run.emphasis_mark = mark
        expect(run.emphasis_mark).to eq(mark)
      end
    end

    it 'returns nil when not set' do
      expect(run.emphasis_mark).to be_nil
    end
  end

  describe '#language' do
    it 'sets and gets language code' do
      run.language = 'en-US'
      expect(run.language).to eq('en-US')
    end

    it 'supports various language codes' do
      codes = %w[en-US fr-FR de-DE ja-JP]
      codes.each do |code|
        run.language = code
        expect(run.language).to eq(code)
      end
    end

    it 'returns nil when not set' do
      expect(run.language).to be_nil
    end
  end

  describe 'combined formatting' do
    it 'applies multiple enhanced properties together' do
      run.character_spacing = 20
      run.kerning = 24
      run.position = 5
      run.text_expansion = 110
      run.outline = true
      run.shadow = true
      run.set_shading(fill: 'FFFF00', pattern: 'solid')

      expect(run.character_spacing).to eq(20)
      expect(run.kerning).to eq(24)
      expect(run.position).to eq(5)
      expect(run.text_expansion).to eq(110)
      expect(run.outline).to be true
      expect(run.shadow).to be true
      expect(run.shading.fill).to eq('FFFF00')
      expect(run.shading.shading_type).to eq('solid')
    end
  end

  describe 'property object creation' do
    it 'creates properties when setting any enhanced property' do
      expect(run.properties).to be_nil

      run.character_spacing = 20

      expect(run.properties).not_to be_nil
      expect(run.properties).to be_a(Uniword::Wordprocessingml::RunProperties)
    end

    it 'reuses existing properties object' do
      run.bold = true
      props_object_id = run.properties.object_id

      run.character_spacing = 20

      expect(run.properties.object_id).to eq(props_object_id)
    end
  end
end
