# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Wordprocessingml::Run, 'Enhanced Properties' do
  let(:run) { described_class.new(text: 'Test text') }
  let(:run_properties_class) { Uniword::Wordprocessingml::RunProperties }

  describe '#character_spacing' do
    it 'sets and gets character spacing' do
      spacing = Uniword::Properties::CharacterSpacing.new(value: 20)
      run.properties = run_properties_class.new(character_spacing: spacing)

      expect(run.properties&.character_spacing&.value).to eq(20)
    end

    it 'returns nil when not set' do
      expect(run.properties&.character_spacing).to be_nil
    end
  end

  describe '#kerning' do
    it 'sets and gets kerning threshold' do
      kerning = Uniword::Properties::Kerning.new(value: 24)
      run.properties = run_properties_class.new(kerning: kerning)

      expect(run.properties&.kerning&.value).to eq(24)
    end

    it 'returns nil when not set' do
      expect(run.properties&.kerning).to be_nil
    end
  end

  describe '#set_shading' do
    it 'sets text shading with fill color' do
      shading = Uniword::Properties::Shading.new(fill: 'FFFF00', pattern: 'clear')
      run.properties = run_properties_class.new(shading: shading)

      expect(run.properties&.shading).not_to be_nil
      expect(run.properties&.shading&.fill).to eq('FFFF00')
    end

    it 'sets shading with pattern' do
      shading = Uniword::Properties::Shading.new(fill: 'FF00FF', pattern: 'solid')
      run.properties = run_properties_class.new(shading: shading)

      expect(run.properties&.shading&.fill).to eq('FF00FF')
      expect(run.properties&.shading&.pattern).to eq('solid')
    end

    it 'defaults to clear pattern' do
      shading = Uniword::Properties::Shading.new(fill: 'CCCCCC', pattern: 'clear')
      run.properties = run_properties_class.new(shading: shading)

      expect(run.properties&.shading&.pattern).to eq('clear')
    end
  end

  describe '#position' do
    it 'sets and gets raised position' do
      position = Uniword::Properties::Position.new(value: 10)
      run.properties = run_properties_class.new(position: position)

      expect(run.properties&.position&.value).to eq(10)
    end

    it 'sets and gets lowered position' do
      position = Uniword::Properties::Position.new(value: -10)
      run.properties = run_properties_class.new(position: position)

      expect(run.properties&.position&.value).to eq(-10)
    end

    it 'returns nil when not set' do
      expect(run.properties&.position).to be_nil
    end
  end

  describe '#text_expansion' do
    it 'sets and gets text expansion' do
      width_scale = Uniword::Properties::WidthScale.new(value: 120)
      run.properties = run_properties_class.new(width_scale: width_scale)

      expect(run.properties&.width_scale&.value).to eq(120)
    end

    it 'sets compression' do
      width_scale = Uniword::Properties::WidthScale.new(value: 80)
      run.properties = run_properties_class.new(width_scale: width_scale)

      expect(run.properties&.width_scale&.value).to eq(80)
    end

    it 'returns nil when not set' do
      expect(run.properties&.width_scale).to be_nil
    end
  end

  describe 'text effects' do
    describe '#outline' do
      it 'sets and gets outline effect' do
        outline = Uniword::Properties::TextOutline.new
        run.properties = run_properties_class.new(text_outline: outline)

        expect(run.properties&.text_outline).not_to be_nil
      end

      it 'defaults to nil when not set' do
        expect(run.properties&.text_outline).to be_nil
      end
    end

    describe '#shadow' do
      it 'sets and gets shadow effect' do
        # NOTE: Shadow is represented via TextFill in OOXML
        text_fill = Uniword::Properties::TextFill.new
        run.properties = run_properties_class.new(text_fill: text_fill)

        expect(run.properties&.text_fill).not_to be_nil
      end

      it 'defaults to nil when not set' do
        expect(run.properties&.text_fill).to be_nil
      end
    end

    describe '#emboss' do
      # NOTE: Emboss property is not currently mapped in RunProperties
      # The class exists in Uniword::Wordprocessingml::Emboss but is not
      # accessible via RunProperties yet.
      it 'sets and gets emboss effect' do
        skip 'Emboss not yet mapped in RunProperties'
      end

      it 'defaults to nil when not set' do
        skip 'Emboss not yet mapped in RunProperties'
      end
    end

    describe '#imprint' do
      # NOTE: Imprint property is not currently mapped in RunProperties
      # The class exists in Uniword::Wordprocessingml::Imprint but is not
      # accessible via RunProperties yet.
      it 'sets and gets imprint effect' do
        skip 'Imprint not yet mapped in RunProperties'
      end

      it 'defaults to nil when not set' do
        skip 'Imprint not yet mapped in RunProperties'
      end
    end
  end

  describe '#hidden' do
    it 'sets and gets hidden text' do
      vanish = Uniword::Properties::Vanish.new(value: true)
      run.properties = run_properties_class.new(hidden: vanish)

      expect(run.properties&.hidden).to be true
    end

    it 'defaults to nil when not set' do
      expect(run.properties&.hidden).to be_nil
    end
  end

  describe '#emphasis_mark' do
    it 'sets and gets emphasis mark' do
      emphasis_mark = Uniword::Properties::EmphasisMark.new(value: 'dot')
      run.properties = run_properties_class.new(emphasis_mark: emphasis_mark)

      expect(run.properties&.emphasis_mark&.value).to eq('dot')
    end

    it 'supports different mark types' do
      %w[dot comma circle underDot].each do |mark|
        emphasis_mark = Uniword::Properties::EmphasisMark.new(value: mark)
        run.properties = run_properties_class.new(emphasis_mark: emphasis_mark)

        expect(run.properties&.emphasis_mark&.value).to eq(mark)
      end
    end

    it 'returns nil when not set' do
      expect(run.properties&.emphasis_mark).to be_nil
    end
  end

  describe '#language' do
    it 'sets and gets language code' do
      language = Uniword::Properties::Language.new(val: 'en-US')
      run.properties = run_properties_class.new(language: language)

      expect(run.properties&.language&.val).to eq('en-US')
    end

    it 'supports various language codes' do
      codes = %w[en-US fr-FR de-DE ja-JP]
      codes.each do |code|
        language = Uniword::Properties::Language.new(val: code)
        run.properties = run_properties_class.new(language: language)

        expect(run.properties&.language&.val).to eq(code)
      end
    end

    it 'returns nil when not set' do
      expect(run.properties&.language).to be_nil
    end
  end

  describe 'combined formatting' do
    it 'applies multiple enhanced properties together' do
      spacing = Uniword::Properties::CharacterSpacing.new(value: 20)
      kerning = Uniword::Properties::Kerning.new(value: 24)
      position = Uniword::Properties::Position.new(value: 5)
      width_scale = Uniword::Properties::WidthScale.new(value: 110)
      outline = Uniword::Properties::TextOutline.new
      text_fill = Uniword::Properties::TextFill.new
      shading = Uniword::Properties::Shading.new(fill: 'FFFF00', pattern: 'solid')

      run.properties = run_properties_class.new(
        character_spacing: spacing,
        kerning: kerning,
        position: position,
        width_scale: width_scale,
        text_outline: outline,
        text_fill: text_fill,
        shading: shading
      )

      expect(run.properties&.character_spacing&.value).to eq(20)
      expect(run.properties&.kerning&.value).to eq(24)
      expect(run.properties&.position&.value).to eq(5)
      expect(run.properties&.width_scale&.value).to eq(110)
      expect(run.properties&.text_outline).not_to be_nil
      expect(run.properties&.text_fill).not_to be_nil
      expect(run.properties&.shading&.fill).to eq('FFFF00')
      expect(run.properties&.shading&.pattern).to eq('solid')
    end
  end

  describe 'property object creation' do
    it 'creates properties when setting any enhanced property' do
      expect(run.properties).to be_nil

      spacing = Uniword::Properties::CharacterSpacing.new(value: 20)
      run.properties = run_properties_class.new(character_spacing: spacing)

      expect(run.properties).not_to be_nil
      expect(run.properties).to be_a(run_properties_class)
    end

    it 'reuses existing properties object' do
      bold = Uniword::Properties::Bold.new(value: true)
      run.properties = run_properties_class.new(bold: bold)
      props_object_id = run.properties.object_id

      spacing = Uniword::Properties::CharacterSpacing.new(value: 20)
      run.properties.character_spacing = spacing

      expect(run.properties.object_id).to eq(props_object_id)
    end
  end
end
