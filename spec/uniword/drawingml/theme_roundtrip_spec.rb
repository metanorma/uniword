# frozen_string_literal: true

require "spec_helper"
require "canon/rspec_matchers"
require "uniword/ooxml/theme_package"

RSpec.describe "Theme Round-Trip (Open-Source YAML)" do
  let(:transformation) { Uniword::Themes::ThemeTransformation.new }

  Uniword::Themes::Theme.available_themes.each do |name|
    describe name do
      let(:friendly_theme) { Uniword::Themes::Theme.load(name) }
      let(:word_theme) { transformation.to_word(friendly_theme) }

      it "loads from YAML successfully" do
        expect(friendly_theme).to be_a(Uniword::Themes::Theme)
        expect(friendly_theme.name).not_to be_nil
        expect(friendly_theme.color_scheme).not_to be_nil
        expect(friendly_theme.font_scheme).not_to be_nil
      end

      it "converts to Word Theme with valid XML" do
        xml = word_theme.to_xml

        expect(xml).to be_a(String)
        expect(xml.length).to be > 100
        expect(xml).to include("xmlns")
        expect(xml).to include("<theme")
        expect(xml).to include("<clrScheme")
        expect(xml).to include("<fontScheme")
      end

      it "round-trips preserving theme name" do
        extracted = transformation.from_word(word_theme)
        expect(extracted.name).to eq(friendly_theme.name)
      end

      it "round-trips preserving color scheme name" do
        expect(word_theme.theme_elements.clr_scheme.name).to eq(friendly_theme.color_scheme.name)
      end

      it "round-trips preserving font scheme name" do
        expect(word_theme.theme_elements.font_scheme.name).to eq(friendly_theme.font_scheme.name)
      end

      it "contains no Microsoft fonts" do
        xml = word_theme.to_xml
        ms_fonts = %w[Calibri Cambria Arial "Segoe UI" Consolas Verdana
                      Georgia Candara Corbel Constantia Aptos "Aptos Display"]
        ms_fonts.each do |font|
          expect(xml).not_to include(font),
            "MS font '#{font}' found in theme #{name}"
        end
      end

      it "has East Asian fonts populated" do
        xml = word_theme.to_xml
        expect(xml).to include("Noto Sans CJK")
      end
    end
  end
end

RSpec.describe "Theme Round-Trip (Binary .thmx)", :theme_roundtrip do
  # Skip if submodule not available (e.g., in CI without SSH access)
  before(:all) do
    skip "Submodule spec/fixtures/uniword-private not available" unless Dir.glob("spec/fixtures/uniword-private/word-resources/office-themes/*.thmx").any?
  end

  # Directory containing reference theme files
  THEME_DIR = "spec/fixtures/uniword-private/word-resources/office-themes"

  # Output directory for round-trip tests
  OUTPUT_DIR = "tmp/theme_roundtrip"

  before(:all) do
    FileUtils.mkdir_p(OUTPUT_DIR)
  end

  after(:all) do
    FileUtils.rm_rf(OUTPUT_DIR)
  end

  # Get all .thmx files from reference directory
  theme_files = Dir.glob(File.join(THEME_DIR, "*.thmx"))

  theme_files.each do |theme_path|
    theme_name = File.basename(theme_path, ".thmx")

    describe theme_name do
      let(:input_path) { theme_path }
      let(:output_path) { File.join(OUTPUT_DIR, "#{theme_name}_roundtrip.thmx") }
      let(:original_package) { Uniword::Ooxml::ThemePackage.new(path: input_path) }
      let(:output_package) { Uniword::Ooxml::ThemePackage.new(path: input_path) }
      let(:verify_package) { Uniword::Ooxml::ThemePackage.new(path: output_path) }

      after do
        original_package.cleanup if original_package.extracted_dir
        output_package.cleanup if output_package.extracted_dir
        verify_package.cleanup if verify_package.extracted_dir
      end

      it "loads theme successfully" do
        theme = original_package.load_content

        expect(theme).to be_a(Uniword::Drawingml::Theme)
        expect(theme.name).to_not be_nil
        expect(theme.color_scheme).to_not be_nil
        expect(theme.font_scheme).to_not be_nil
      end

      it "serializes theme to valid XML" do
        theme = original_package.load_content

        xml = theme.to_xml

        expect(xml).to_not be_nil
        expect(xml).to be_a(String)
        expect(xml.length).to be > 100
        expect(xml).to include("xmlns")
        expect(xml).to include("drawingml")
      end

      it "round-trips theme preserving structure" do
        original_theme = original_package.load_content

        output_package.extract
        output_package.save_content(original_theme)
        output_package.package(output_path)

        expect(File.exist?(output_path)).to be true
        expect(File.size(output_path)).to be > 0

        roundtrip_theme = verify_package.load_content

        expect(roundtrip_theme.name).to eq(original_theme.name)
        expect(roundtrip_theme.color_scheme.name).to eq(original_theme.color_scheme.name)
        expect(roundtrip_theme.font_scheme.name).to eq(original_theme.font_scheme.name)
      end

      it "round-trips theme XML semantically equivalent" do
        original_theme = original_package.load_content
        original_xml = original_package.read_theme

        output_package.extract
        output_package.save_content(original_theme)
        output_package.package(output_path)

        verify_package.extract
        regenerated_xml = verify_package.read_theme

        expect(regenerated_xml).to be_xml_equivalent_to(original_xml)
      end

      it "preserves color scheme colors" do
        original_theme = original_package.load_content

        output_package.extract
        output_package.save_content(original_theme)
        output_package.package(output_path)

        roundtrip_theme = verify_package.load_content

        Uniword::Drawingml::ColorScheme::THEME_COLORS.each do |color_name|
          original_color = original_theme.color_scheme[color_name]
          roundtrip_color = roundtrip_theme.color_scheme[color_name]

          expect(roundtrip_color).to eq(original_color),
                                     "Color #{color_name} mismatch: #{roundtrip_color} != #{original_color}"
        end
      end

      it "preserves font scheme fonts" do
        original_theme = original_package.load_content

        output_package.extract
        output_package.save_content(original_theme)
        output_package.package(output_path)

        roundtrip_theme = verify_package.load_content

        expect(roundtrip_theme.major_font).to eq(original_theme.major_font)
        expect(roundtrip_theme.minor_font).to eq(original_theme.minor_font)
      end
    end
  end

  after(:all) do
    total_themes = Dir.glob(File.join(THEME_DIR, "*.thmx")).count
    puts
    puts "=" * 60
    puts "Theme Round-Trip Summary"
    puts "=" * 60
    puts "Total Themes tested: #{total_themes}"
    puts "=" * 60
    puts
  end
end
