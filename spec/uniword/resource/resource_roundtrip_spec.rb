# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe 'Resource Roundtrip' do
  describe 'Theme roundtrip' do
    let(:temp_dir) { Dir.mktmpdir('uniword_theme_roundtrip') }
    let(:original_yaml) { File.join(temp_dir, 'original.yml') }
    let(:roundtrip_yaml) { File.join(temp_dir, 'roundtrip.yml') }
    let(:xml_path) { File.join(temp_dir, 'theme.xml') }
    let(:transformation) { Uniword::Themes::ThemeTransformation.new }

    after do
      FileUtils.rm_rf(temp_dir)
    end

    context 'bundled themes' do
      Uniword::Themes::Theme.available_themes.each do |theme_name|
        describe theme_name do
          it 'roundtrips through YAML' do
            # Load friendly theme
            friendly = Uniword::Themes::Theme.load(theme_name)

            # Save to YAML
            File.write(original_yaml, friendly.to_yaml)

            # Load from YAML
            loaded = Uniword::Themes::Theme.from_yaml(File.read(original_yaml))

            # Save again
            File.write(roundtrip_yaml, loaded.to_yaml)

            # Compare
            expect(File.read(roundtrip_yaml)).to be_yaml_equivalent_to(File.read(original_yaml))
          end

          it 'roundtrips through XML' do
            # Load friendly theme and convert to Word theme
            friendly = Uniword::Themes::Theme.load(theme_name)
            original = transformation.to_word(friendly)

            # Save to XML
            File.write(xml_path, original.to_xml)

            # Load from XML
            loaded = Uniword::Drawingml::Theme.from_xml(File.read(xml_path))

            # Compare key attributes
            expect(loaded.name).to eq(original.name)
          end
        end
      end
    end

    context 'theme with color scheme' do
      it 'preserves color scheme colors' do
        friendly = Uniword::Themes::Theme.load('atlas')
        theme = transformation.to_word(friendly)

        yaml = theme.to_yaml
        loaded = Uniword::Drawingml::Theme.from_yaml(yaml)

        expect(loaded.color_scheme.name).to eq(theme.color_scheme.name)
        %i[dk1 lt1 dk2 lt2 accent1 accent2 accent3 accent4 accent5 accent6 hlink fol_hlink].each do |color|
          original_color = theme.color_scheme.send(color)
          loaded_color = loaded.color_scheme.send(color)

          # Compare color values if present (colors have nested srgb_clr or sys_clr with val)
          if original_color && loaded_color
            original_val = original_color.srgb_clr&.val || original_color.sys_clr&.val
            loaded_val = loaded_color.srgb_clr&.val || loaded_color.sys_clr&.val
            expect(loaded_val).to eq(original_val) if original_val && loaded_val
          end
        end
      end
    end

    context 'theme with font scheme' do
      it 'preserves font scheme fonts' do
        friendly = Uniword::Themes::Theme.load('atlas')
        theme = transformation.to_word(friendly)

        yaml = theme.to_yaml
        loaded = Uniword::Drawingml::Theme.from_yaml(yaml)

        expect(loaded.font_scheme.name).to eq(theme.font_scheme.name)

        if theme.font_scheme.major_font_obj&.latin && loaded.font_scheme.major_font_obj&.latin
          expect(loaded.font_scheme.major_font_obj.latin.typeface).to eq(theme.font_scheme.major_font_obj.latin.typeface)
        end

        if theme.font_scheme.minor_font_obj&.latin && loaded.font_scheme.minor_font_obj&.latin
          expect(loaded.font_scheme.minor_font_obj.latin.typeface).to eq(theme.font_scheme.minor_font_obj.latin.typeface)
        end
      end
    end
  end

  describe 'StyleSet roundtrip' do
    let(:temp_dir) { Dir.mktmpdir('uniword_styleset_roundtrip') }
    let(:original_yaml) { File.join(temp_dir, 'original.yml') }
    let(:roundtrip_yaml) { File.join(temp_dir, 'roundtrip.yml') }

    after do
      FileUtils.rm_rf(temp_dir)
    end

    context 'bundled stylesets' do
      Uniword::StyleSet.available_stylesets.first(3).each do |styleset_name|
        describe styleset_name do
          it 'roundtrips through YAML' do
            # Load original
            original = Uniword::StyleSet.load(styleset_name)

            # Save to YAML
            File.write(original_yaml, original.to_yaml)

            # Load from YAML
            loaded = Uniword::Wordprocessingml::StylesConfiguration.from_yaml(File.read(original_yaml))

            # Save again
            File.write(roundtrip_yaml, loaded.to_yaml)

            # Compare style count
            expect(loaded.styles.count).to eq(original.styles.count)
          end
        end
      end
    end
  end

  describe 'DOCX extraction' do
    let(:temp_dir) { Dir.mktmpdir('uniword_docx_extraction') }
    let(:docx_path) { File.join(temp_dir, 'document.docx') }
    let(:extracted_theme) { File.join(temp_dir, 'extracted_theme.yml') }
    let(:extracted_styleset) { File.join(temp_dir, 'extracted_styleset.yml') }

    after do
      FileUtils.rm_rf(temp_dir)
    end

    before do
      # Create a document with theme and styleset
      doc = Uniword::Wordprocessingml::DocumentRoot.new
      para = Uniword::Wordprocessingml::Paragraph.new
      run = Uniword::Wordprocessingml::Run.new(text: 'Test paragraph')
      para.runs << run
      doc.body.paragraphs << para
      doc.apply_theme('atlas')
      doc.apply_styleset('distinctive')
      doc.save(docx_path)
    end

    it 'extracts theme from DOCX' do
      doc = Uniword::DocumentFactory.from_file(docx_path)

      expect(doc.theme).not_to be_nil
      expect(doc.theme.name).to include('Atlas')

      # Save extracted theme
      File.write(extracted_theme, doc.theme.to_yaml)

      # Verify it can be loaded
      loaded = Uniword::Drawingml::Theme.from_yaml(File.read(extracted_theme))
      expect(loaded.name).to include('Atlas')
    end

    it 'extracts styleset from DOCX' do
      doc = Uniword::DocumentFactory.from_file(docx_path)

      expect(doc.styles_configuration).not_to be_nil

      # Save extracted styleset
      File.write(extracted_styleset, doc.styles_configuration.to_yaml)

      # Verify it can be loaded
      loaded = Uniword::Wordprocessingml::StylesConfiguration.from_yaml(File.read(extracted_styleset))
      expect(loaded.styles.count).to be > 0
    end
  end

  describe 'Resource processing' do
    let(:transformation) { Uniword::Themes::ThemeTransformation.new }

    describe 'ColorTransformer' do
      it 'transforms colors consistently' do
        original = '#FF0000' # Red

        # Transform with known shifts
        result = Uniword::Resource::ColorTransformer.shift_color(
          original,
          hue_shift: 180,
          saturation_shift: 0,
          lightness_shift: 0
        )

        # Red shifted 180 degrees should be cyan-ish
        expect(result).to match(/#[0-9A-F]{6}/)
        expect(result).not_to eq(original)
      end

      it 'preserves color with zero shifts' do
        original = '#FF0000'

        result = Uniword::Resource::ColorTransformer.shift_color(
          original,
          hue_shift: 0,
          saturation_shift: 0,
          lightness_shift: 0
        )

        expect(result).to eq(original)
      end
    end

    describe 'FontSubstitutor' do
      it 'substitutes MS fonts with open-source alternatives' do
        expect(Uniword::Resource::FontSubstitutor.substitute('Calibri')).to eq('Carlito')
        expect(Uniword::Resource::FontSubstitutor.substitute('Arial')).to eq('Liberation Sans')
        expect(Uniword::Resource::FontSubstitutor.substitute('Times New Roman')).to eq('Liberation Serif')
      end

      it 'returns original font when no substitution exists' do
        expect(Uniword::Resource::FontSubstitutor.substitute('Unknown Font')).to eq('Unknown Font')
      end
    end

    describe 'ThemeProcessor' do
      it 'creates deterministic processor from seed' do
        processor1 = Uniword::Resource::ThemeProcessor.from_seed('test-seed')
        processor2 = Uniword::Resource::ThemeProcessor.from_seed('test-seed')

        expect(processor1.hue_shift).to eq(processor2.hue_shift)
        expect(processor1.saturation_shift).to eq(processor2.saturation_shift)
        expect(processor1.lightness_shift).to eq(processor2.lightness_shift)
      end

      it 'creates identity processor' do
        processor = Uniword::Resource::ThemeProcessor.identity

        expect(processor.hue_shift).to eq(0)
        expect(processor.saturation_shift).to eq(0)
        expect(processor.lightness_shift).to eq(0)
        expect(processor.identity?).to be true
      end

      it 'processes theme creating variant' do
        friendly = Uniword::Themes::Theme.load('atlas')
        theme = transformation.to_word(friendly)
        processor = Uniword::Resource::ThemeProcessor.new(
          hue_shift: 10,
          saturation_shift: 5,
          lightness_shift: -5
        )

        processed = processor.process(theme)

        expect(processed).to be_a(Uniword::Drawingml::Theme)
        expect(processed.name).to include('Atlas')
        expect(processed.name).to include('Uniword')
      end
    end
  end
end
